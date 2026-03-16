# Context Nate — Nate's Newsletter Prompt Kit + MyBCAT Application

## What This Repo Is
A curated knowledge base combining Nate's Newsletter frameworks and prompt kits with MyBCAT-specific business context and generated outputs. Used as context for future AI builds across all MyBCAT projects.

## Directory Structure
- `prompts/` — Raw prompt kits from Nate's Newsletter, archived by date and topic
- `outputs/` — Generated outputs applying Nate's prompts to MyBCAT data
- `references/` — Business context, frameworks, and reference material
- `skill/` — Reusable Claude Code skill for invoking Nate's frameworks

## Key Files
- `outputs/CLAUDE-UNIVERSAL.md` — Universal rules file for all MyBCAT repos (symlink target)
- `references/mybcat-business-context.md` — Comprehensive business context for prompt application
- `references/nate-frameworks.md` — Nate's core frameworks and prompt patterns

## How to Use
1. When applying a Nate prompt kit to MyBCAT, read `references/mybcat-business-context.md` for pre-gathered answers
2. When building new features, check `outputs/CLAUDE-UNIVERSAL.md` for rules to follow
3. When creating new prompt kits, follow Nate's universal structure: `<role>`, `<instructions>`, `<output>`, `<guardrails>`

## MCP Access
- **Nate's Newsletter MCP:** `search_posts`, `search_prompts`, `get_post`, `list_posts` — 504 posts, all prompt kits indexed
- **MyBCAT Ops MCP:** `search`, `search_client`, `list_docs` — 1,126 docs, 73K chunks
- **AWS MCP:** 102 read-only tools for infrastructure inspection

## Rules
- Never fabricate business data. Always query MCPs for current state.
- Nate's prompts are interactive — when applying to MyBCAT, use MCP data as the "user answers."
- Keep universal rules file under 100 lines. Grow from incidents, not brainstorming.
- PHI must never appear in any output file. Scrub before writing.
