#!/usr/bin/env python3
"""
MyBCAT Playbook MCP Server

Exposes semantic search and retrieval over MyBCAT operational playbook
documents stored in PostgreSQL/pgvector.

URL: https://rag.mybcat.com/playbook/sse?key=YOUR_SECRET_KEY
Port: 8767 (reverse-proxied by Caddy at /playbook/)
"""

import os
import logging
from pathlib import Path
from typing import Optional

# ─── Load .env ───────────────────────────────────────────────────────────────

env_file = Path("/opt/mybcat-playbook/.env")
if env_file.exists():
    with open(env_file) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.split("=", 1)
                os.environ[key] = value.strip('"').strip("'")

# ─── Auth ────────────────────────────────────────────────────────────────────

SECRET_KEY = os.environ.get("MCP_SECRET_KEY", "")

# ─── DB + Embedding (lazy) ───────────────────────────────────────────────────

_db_conn = None
_model = None

DB_HOST = os.environ.get("DB_HOST", "")
DB_PORT = int(os.environ.get("DB_PORT", "5432"))
DB_NAME = os.environ.get("DB_NAME", "")
DB_USER = os.environ.get("DB_USER", "")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "")
EMBEDDING_DIM = 768
EMBEDDING_MODEL = "all-mpnet-base-v2"

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)


def get_db():
    global _db_conn
    import psycopg2

    if _db_conn is None or _db_conn.closed:
        _db_conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            connect_timeout=15,
            sslmode="require",
        )
        _db_conn.autocommit = True
    return _db_conn


def get_model():
    global _model
    if _model is None:
        from sentence_transformers import SentenceTransformer

        logger.info(f"Loading embedding model: {EMBEDDING_MODEL}")
        _model = SentenceTransformer(EMBEDDING_MODEL)
        logger.info("Embedding model loaded")
    return _model


def embed(text: str) -> str:
    """Return PostgreSQL vector literal string for text."""
    text = text[:8000]
    model = get_model()
    vec = model.encode(text, normalize_embeddings=True).tolist()
    return "[" + ",".join(str(v) for v in vec) + "]"


# ─── MCP Server ──────────────────────────────────────────────────────────────

from mcp.server.fastmcp import FastMCP
from mcp.server.transport_security import TransportSecuritySettings
from starlette.responses import JSONResponse

transport_settings = TransportSecuritySettings(enable_dns_rebinding_protection=False)

mcp = FastMCP(
    "mybcat-playbook",
    instructions=(
        "Search MyBCAT operational playbook documents including security audits, "
        "business context, procedures, rules, onboarding materials, and Nate "
        "framework outputs. Use search_playbook for semantic topic search, "
        "get_playbook_doc to retrieve a full document by filename, and "
        "list_playbook to browse available documents."
    ),
    transport_security=transport_settings,
)


@mcp.tool()
def search_playbook(query: str, category: Optional[str] = None, limit: int = 5) -> list:
    """
    Semantic search across MyBCAT playbook documents.

    Args:
        query: Natural language search query
        category: Optional category filter
        limit: Max results to return (default 5)

    Returns:
        List of {title, category, filename, score, excerpt} dicts
    """
    vec = embed(query)
    conditions = ["embedding IS NOT NULL"]
    params = []

    if category:
        conditions.append("category = %s")
        params.append(category)

    where = " AND ".join(conditions)

    sql = f"""
        SELECT title, category, filename,
               1 - (embedding <=> %s::vector) AS score,
               LEFT(content_text, 800) AS excerpt
        FROM context_outputs
        WHERE {where}
        ORDER BY embedding <=> %s::vector
        LIMIT %s
    """
    params_full = [vec] + params + [vec, limit]

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(sql, params_full)
        rows = cur.fetchall()

    return [
        {
            "title": r[0],
            "category": r[1],
            "filename": r[2],
            "score": round(float(r[3]), 4),
            "excerpt": r[4] or "",
        }
        for r in rows
    ]


@mcp.tool()
def get_playbook_doc(filename: str) -> dict:
    """
    Retrieve full content of a playbook document by filename.

    Args:
        filename: Full filename or partial filename match

    Returns:
        {title, category, filename, created_date, content_text}
    """
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT title, category, filename, created_date, content_text
            FROM context_outputs
            WHERE filename ILIKE %s
            LIMIT 1
            """,
            [f"%{filename}%"],
        )
        row = cur.fetchone()

    if not row:
        return {"error": f"No playbook document found matching: {filename}"}

    return {
        "title": row[0],
        "category": row[1],
        "filename": row[2],
        "created_date": str(row[3]) if row[3] else None,
        "content_text": row[4] or "",
    }


@mcp.tool()
def list_playbook(category: Optional[str] = None) -> list:
    """
    List all available playbook documents, optionally filtered by category.

    Args:
        category: Optional category filter

    Returns:
        List of {title, category, filename, created_date} dicts
    """
    conditions = []
    params = []

    if category:
        conditions.append("category = %s")
        params.append(category)

    where = "WHERE " + " AND ".join(conditions) if conditions else ""

    sql = f"""
        SELECT title, category, filename, created_date
        FROM context_outputs
        {where}
        ORDER BY category, filename
    """

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(sql, params)
        rows = cur.fetchall()

    return [
        {
            "title": r[0],
            "category": r[1],
            "filename": r[2],
            "created_date": str(r[3]) if r[3] else None,
        }
        for r in rows
    ]


# ─── Auth + ASGI App ─────────────────────────────────────────────────────────


def create_app():
    mcp_sse_app = mcp.sse_app()

    async def auth_wrapper(scope, receive, send):
        query_string = scope.get("query_string", b"").decode()
        params = {}
        for p in query_string.split("&"):
            if "=" in p:
                k, v = p.split("=", 1)
                params[k] = v
        key = params.get("key", "")

        headers = dict(scope.get("headers", []))
        auth_header = headers.get(b"authorization", b"").decode()
        bearer_key = auth_header[7:] if auth_header.startswith("Bearer ") else ""

        if SECRET_KEY and (key == SECRET_KEY or bearer_key == SECRET_KEY):
            return await mcp_sse_app(scope, receive, send)

        response = JSONResponse(
            {"error": "unauthorized", "error_description": "Invalid or missing key"},
            status_code=401,
        )
        await response(scope, receive, send)

    async def health_app(scope, receive, send):
        if scope["type"] == "http":
            response = JSONResponse({"status": "healthy", "service": "mybcat-playbook-mcp"})
            await response(scope, receive, send)

    async def main_app(scope, receive, send):
        path = scope.get("path", "")

        # Inject root_path so the MCP SSE transport returns the correct
        # /playbook/messages/... URL to clients when reverse-proxied.
        if scope.get("type") in ("http", "websocket"):
            scope = dict(scope)
            scope["root_path"] = "/playbook"

        if path == "/health":
            await health_app(scope, receive, send)
        elif path.startswith("/sse"):
            await auth_wrapper(scope, receive, send)
        elif path.startswith("/messages"):
            # Session IDs are unguessable — allow through.
            await mcp_sse_app(scope, receive, send)
        else:
            response = JSONResponse({"error": "not_found"}, status_code=404)
            await response(scope, receive, send)

    return main_app


# ─── Entry Point ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import uvicorn

    print("=" * 60)
    print("MyBCAT Playbook MCP Server")
    print("=" * 60)
    print()
    print("SSE endpoint:")
    print(f"  https://rag.mybcat.com/playbook/sse?key={SECRET_KEY}")
    print()
    print("=" * 60)

    app = create_app()
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8767,
        forwarded_allow_ips="*",
        proxy_headers=True,
    )
