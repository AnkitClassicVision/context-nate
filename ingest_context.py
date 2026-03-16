#!/usr/bin/env python3
"""
Ingest context_nate markdown files into the Nate Substack MCP PostgreSQL database.

Creates the context_outputs table if it doesn't exist, reads all markdown files
from outputs/, references/, and prompts/, generates embeddings, and upserts them.

Usage:
    python3 ingest_context.py                    # ingest all files
    python3 ingest_context.py --file outputs/01-operational-advisor-diagnostic.md  # single file

Requires: psycopg2, sentence-transformers
DB credentials from environment or .env file.
"""

import os
import sys
import argparse
from pathlib import Path

# Load .env if present
for env_path in [Path(".env"), Path("/opt/nate-substack-mcp/.env")]:
    if env_path.exists():
        with open(env_path) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, value = line.split("=", 1)
                    os.environ[key] = value.strip('"').strip("'")
        break

import psycopg2
from sentence_transformers import SentenceTransformer

DB_HOST = os.environ.get("DB_HOST", "")
DB_PORT = int(os.environ.get("DB_PORT", "5432"))
DB_NAME = os.environ.get("DB_NAME", "")
DB_USER = os.environ.get("DB_USER", "")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "")

EMBEDDING_MODEL = "all-mpnet-base-v2"
CONTEXT_DIR = Path(__file__).parent

# Map subdirectories to categories
CATEGORY_MAP = {
    "outputs": "output",
    "references": "reference",
    "prompts": "prompt",
}


def get_db():
    conn = psycopg2.connect(
        host=DB_HOST, port=DB_PORT, dbname=DB_NAME,
        user=DB_USER, password=DB_PASSWORD,
        connect_timeout=15, sslmode="require",
    )
    conn.autocommit = True
    return conn


def ensure_table(conn):
    """Create the context_outputs table if it doesn't exist."""
    with conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS context_outputs (
                output_id    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                filename     TEXT UNIQUE NOT NULL,
                title        TEXT NOT NULL DEFAULT '',
                category     TEXT NOT NULL DEFAULT 'output',
                content_text TEXT NOT NULL DEFAULT '',
                created_date DATE DEFAULT CURRENT_DATE,
                updated_at   TIMESTAMPTZ DEFAULT NOW(),
                embedding    vector(768)
            );
            CREATE INDEX IF NOT EXISTS context_outputs_embedding_idx
                ON context_outputs USING ivfflat (embedding vector_cosine_ops)
                WITH (lists = 10);
            CREATE INDEX IF NOT EXISTS context_outputs_category_idx
                ON context_outputs (category);
        """)
    print("Table context_outputs ready.")


def extract_title(content: str, filename: str) -> str:
    """Extract the first H1 heading as title, or use filename."""
    for line in content.split("\n"):
        line = line.strip()
        if line.startswith("# "):
            return line[2:].strip()
    return filename.replace("-", " ").replace(".md", "").title()


def collect_files(single_file: str = None) -> list:
    """Collect markdown files to ingest."""
    files = []

    if single_file:
        path = CONTEXT_DIR / single_file
        if path.exists():
            # Determine category from path
            rel = path.relative_to(CONTEXT_DIR)
            subdir = rel.parts[0] if len(rel.parts) > 1 else "output"
            category = CATEGORY_MAP.get(subdir, "output")
            files.append((path, category))
        else:
            print(f"File not found: {path}")
        return files

    for subdir, category in CATEGORY_MAP.items():
        dir_path = CONTEXT_DIR / subdir
        if dir_path.exists():
            for md_file in sorted(dir_path.glob("*.md")):
                files.append((md_file, category))

    # Also include CLAUDE-UNIVERSAL.md as "rules" category
    universal = CONTEXT_DIR / "outputs" / "CLAUDE-UNIVERSAL.md"
    # It's already in outputs, but let's tag it as "rules" via override
    return files


def main():
    parser = argparse.ArgumentParser(description="Ingest context files into PostgreSQL")
    parser.add_argument("--file", help="Single file to ingest (relative to context_nate/)")
    args = parser.parse_args()

    print(f"Loading embedding model: {EMBEDDING_MODEL}")
    model = SentenceTransformer(EMBEDDING_MODEL)
    print("Model loaded.")

    conn = get_db()
    ensure_table(conn)

    files = collect_files(args.file)
    print(f"Found {len(files)} files to ingest.")

    for filepath, category in files:
        content = filepath.read_text(encoding="utf-8")
        filename = filepath.name
        title = extract_title(content, filename)

        # Override category for CLAUDE-UNIVERSAL
        if filename == "CLAUDE-UNIVERSAL.md":
            category = "rules"

        # Generate embedding from title + first 7500 chars of content
        embed_text = f"{title}\n\n{content[:7500]}"
        vec = model.encode(embed_text, normalize_embeddings=True).tolist()
        vec_str = "[" + ",".join(str(v) for v in vec) + "]"

        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO context_outputs (filename, title, category, content_text, embedding, updated_at)
                VALUES (%s, %s, %s, %s, %s::vector, NOW())
                ON CONFLICT (filename)
                DO UPDATE SET
                    title = EXCLUDED.title,
                    category = EXCLUDED.category,
                    content_text = EXCLUDED.content_text,
                    embedding = EXCLUDED.embedding,
                    updated_at = NOW()
            """, [filename, title, category, content, vec_str])

        print(f"  ✓ {category}/{filename} — {title}")

    conn.close()
    print(f"\nDone. {len(files)} files ingested.")


if __name__ == "__main__":
    main()
