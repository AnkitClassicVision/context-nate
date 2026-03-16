# MyBCAT MCP & Data Sources Inventory
**Last updated: 2026-03-16**

---

## MCP Servers (VPS — rag.mybcat.com)

| Service | Port | Caddy Route | URL | What It Searches |
|---------|------|-------------|-----|-----------------|
| **mybcat-rag** | 8765 | default (`/`) | `rag.mybcat.com/sse?key=MCP_API_KEY` | ~100 blog posts, ~98 podcast episodes with transcripts from mybcat.com |
| **nate-substack** | 8766 | `/nate-substack/` | `rag.mybcat.com/nate-substack/sse` | 504 Nate newsletter posts, prompt kits, linked content |
| **mybcat-ops (ops-rag)** | 8767 | `/ops/` | `rag.mybcat.com/ops/sse` | 1,126 docs: meetings (Fathom), Monday.com, Drive docs, team chat |
| **mybcat-taste** | 8768 | `/taste/` | `rag.mybcat.com/taste/sse` | AI interaction preferences, style corrections, taste signals |
| **mybcat-playbook** | 8769 | `/playbook/` | `rag.mybcat.com/playbook/sse` | Full operational playbook: security audit, business context, rules, procedures, frameworks |
| **aws-mcp** | 8900 | `/aws/` | `rag.mybcat.com/aws/sse` | 102 read-only AWS tools: billing, Connect, DynamoDB, Lambda, ECS, RDS, S3, networking, security |

## Claude Desktop (claude.ai) MCPs

| Name in Claude Desktop | Maps To | Tools |
|------------------------|---------|-------|
| **MyBcat-Ops** | ops-rag-mcp (port 8767) | `search`, `search_client`, `list_docs`, `get_document`, `stats` |
| **aws-info** | aws-mcp (port 8900) | 102 tools across billing, Connect, DynamoDB, Lambda, ECS, RDS, S3, etc. |
| **Taste_MCP** | mybcat-taste (port 8768) | `log_signal`, `search_taste_preferences`, `add_preference`, `get_taste_profile`, etc. |
| **Nate-substack-MCP** | nate-substack (port 8766) | `search_posts`, `search_prompts`, `search_linked_content`, `get_post`, `list_posts` |
| **mybcat-playbook** | mybcat-playbook (port 8769) | `search_playbook`, `get_playbook_doc`, `list_playbook` |
| **Gmail** | Google API (OAuth) | `gmail_search_messages`, `gmail_read_message`, `gmail_create_draft`, etc. |
| **Google Calendar** | Google API (OAuth) | `gcal_list_events`, `gcal_create_event`, `gcal_find_free_time`, etc. |
| **HubSpot** | HubSpot API | `get_crm_objects`, `search_crm_objects`, `manage_crm_objects`, `search_owners`, etc. |

## Claude Code MCPs (settings.json)

| Name | URL |
|------|-----|
| **nate-substack** | `rag.mybcat.com/nate-substack/sse` |
| **mybcat-playbook** | `rag.mybcat.com/playbook/sse` |

## Skills (87 total — key data-connected ones)

### CRM & Sales
| Skill | Data Source | Access Type |
|-------|-------------|-------------|
| `/hubspot` | HubSpot API | Read/Write — contacts, deals, companies, invoices, automation |
| `/gohighlevel` | GoHighLevel API v2 | Read/Write — full CRM, pipelines, workflows, social posting |
| `/monday-com` | Monday.com GraphQL | Read/Write — boards, items, columns, updates |
| `/linkedin` | Unipile API | Send messages, connection requests |

### Finance & Billing
| Skill | Data Source | Access Type |
|-------|-------------|-------------|
| `/quickbooks` | QuickBooks Online API | Read/Write — invoices, customers, vendors, P&L, balance sheet |
| `/quickbooks-cvc` | QuickBooks (CVC account) | Read/Write — separate CVC Finance entity |
| `/bill-com` | Bill.com v3 API | Read/Write — AP/AR, payments, vendors, virtual cards |
| `/plaid` | Plaid API | Read — bank transactions, account balances |
| `/mybcat-ar` | Internal data | Read — AR/AP reconciliation, billing flags, revenue projections |

### Marketing & SEO
| Skill | Data Source | Access Type |
|-------|-------------|-------------|
| `/ahrefs` | Ahrefs API | Read — backlinks, keywords, SERP, site audits |
| `/dataforseo` | DataForSEO API | Read — SERP, keywords, backlinks, business data, reviews |
| `/google-search-console` | Google Search Console | Read — keywords, performance, clicks, impressions |
| `/google-analytics` | Google Analytics 4 | Read — traffic, campaigns, social performance |
| `/google-business-profile` | Google Business Profile | Read/Write — listings, hours, phone, website |
| `/bing-web-tools` | Bing Webmaster Tools | Read/Write — sitemaps, URL submission, IndexNow |
| `/blotato` | Blotato API | Write — schedule/publish to LinkedIn, Facebook, Instagram, X, TikTok |
| `/exa` | Exa.ai API | Read — neural web search, people finder (1B+ profiles), company research |
| `/seo-audit` | squirrelscan CLI | Read — 230+ rules, health scores, broken links |
| `/audit-website` | squirrelscan CLI | Read — SEO, performance, security, content audit |
| `/mybcat-blog` | mybcat-new repo | Read/Write — list, create, publish, schedule blog posts |

### Communication
| Skill | Data Source | Access Type |
|-------|-------------|-------------|
| `/gmail` | Gmail API (OAuth) | Read/Write — send, read, draft emails (ankit@mybcat.com) |
| `/sakari_sms` | Sakari API | Write — send SMS, log to HubSpot |
| `/thanks-io` | Thanks.io API | Write — send postcards, campaigns |

### AI & Research
| Skill | Data Source | Access Type |
|-------|-------------|-------------|
| `/codex` | OpenAI Codex CLI | Read/Write — code reviews, implementations, second opinions |
| `/gemini` | Google Gemini CLI | Read-only — large context analysis, research, red teaming |
| `/localllm` | Ollama (local) | Read — query Qwen, Llama, Mistral locally |
| `/perplexity` | Perplexity AI | Read — deep web search, source validation |
| `/google-search` | Google Custom Search | Read — web search |
| `/agent-team` | Codex + Gemini + Claude | Read — ensemble research from 3 AI perspectives |
| `/nanobanana` | Google Gemini API | Write — generate/edit images |

### AWS & Infrastructure
| Skill | Data Source | Access Type |
|-------|-------------|-------------|
| `/aws` | AWS CLI | Read/Write — ECS, RDS, S3, ECR, CloudWatch, Secrets Manager, Terraform |
| `/aws-data` | AWS MCP (102 tools) | Read-only — billing, infrastructure, Connect, DynamoDB, Lambda, logs |
| `/cloudflare` | Cloudflare API | Read/Write — DNS, cache, WAF, SSL, analytics |
| `/vercel` | Vercel CLI | Read/Write — deployments, domains, env vars |

### Voice & Phone
| Skill | Data Source | Access Type |
|-------|-------------|-------------|
| `/bland-ai` | Bland AI API | Read/Write — voice agents, pathways, inbound/outbound calls |
| `/fathom` | Fathom API | Read — meeting recordings, transcripts, AI summaries, action items |

### Knowledge Bases
| Skill | Data Source | Records | Access |
|-------|-------------|---------|--------|
| `/mybcat-rag` | Supabase (pgvector) | ~100 blogs + ~98 podcast episodes | Read — semantic search with reranking |
| `/mybcat-ops` | ops-rag MCP | 1,126 docs, 73K chunks | Read — meetings, Monday, Drive, chat |
| `/playbook` | playbook MCP | 9 operational docs | Read — security audit, business context, frameworks |
| `/nate` | nate-substack MCP | 504 posts + prompt kits | Read — newsletter search, framework application |
| `/taste` | taste MCP | Preference signals | Read/Write — capture and serve AI interaction preferences |

### Health & Productivity
| Skill | Data Source | Access Type |
|-------|-------------|-------------|
| `/whoop` | Whoop API | Read — recovery, sleep, strain, HRV, workouts |
| `/google-calendar` | Google Calendar API | Read/Write — events, free time, meeting tracking |

### Databases (Direct)
| Skill | Database | Access |
|-------|----------|--------|
| `/supabase_opto` | Supabase (OptometryConnect) | Full CRUD — tables, storage, auth, raw SQL |

### Media & Content
| Skill | Tool | Access |
|-------|------|--------|
| `/remotion` | Remotion (React video) | Write — render videos, audiograms, social clips |
| `/ffmpeg` | FFmpeg CLI | Write — audio/video processing, conversion, editing |
| `/marp` | Marp CLI | Write — markdown to HTML/PPTX/PDF presentations |
| `/ocr` | PaddleOCR (GPU) | Read — extract text from PDFs/images |

### Operations & Compliance
| Skill | Purpose |
|-------|---------|
| `/phi` | MANDATORY — scrub PHI/PII before sending docs to LLM |
| `/daily-report` | Generate client reports from Monday.com data |
| `/oystehr-zambda-deploy` | Deploy Ottehr/Oystehr serverless functions |
| `/repair-bot-test` | Test repair bot before VPS deployment |

### Development Workflow
| Skill | Purpose |
|-------|---------|
| `/github-operations` | Push code, create repos/PRs, manage GitHub |
| `/agent-browser` | Playwright-based web automation |
| `/claude-computer-use` | Full browser automation via Claude |
| `/command-runner` | Execute shell commands |
| `/command-orchestrator` | Multi-step terminal workflows |
| `/skill-creator` | Create new skills with guidelines enforcement |
| `/prompt_writer` | Rewrite prompts using C-I-C-E-O structure |
| `/agent_spec_writer` | Write specs for autonomous AI agents |

---

## Summary Counts

| Category | Count |
|----------|-------|
| VPS MCP servers | 6 |
| Claude Desktop MCPs | 8 |
| Claude Code MCPs | 2 |
| Skills (total) | 87 |
| Skills with external data access | 55+ |
| Databases (PostgreSQL) | 10 RDS instances + 2 Supabase |
| DynamoDB tables | 23 |
| Knowledge base chunks | 73K+ (ops) + 504 posts (nate) + ~200 blogs/podcasts (rag) |
| AWS Secrets Manager | 217 secrets |
