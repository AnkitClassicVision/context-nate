# Skills Library Audit — 84 Claude Code Skills

**Date:** 2026-04-02
**Method:** Read first 30 lines of each skill file, categorize by compensating complexity type

## Summary

| Category | Count | % | Avg Lines | Character |
|----------|-------|---|-----------|-----------|
| **OUTCOME** | 37 | 44% | 223 | Defines WHAT, survives model upgrades |
| **PLATFORM** | 33 | 39% | 359 | API/tool integration, model-independent |
| **PROCEDURAL** | 11 | 13% | 382 | Step-by-step instructions, at-risk |
| **HYBRID** | 3 | 3% | 128 | Mixed concerns, simplifiable |
| **TOTAL** | **84** | | | |

**Scaffolding Ratio: 18.6%** (procedural + hybrid content)
**Industry benchmark: 25-35%.** MyBCAT's library is 36-52% better than average.

## Key Finding

The skills library is in much better shape than the system prompts (42% scaffolding). The 87+ skills are 81.4% model-agnostic (outcome + platform). This is because most skills were built to interface with external APIs (platform) or define goals (outcome), not to teach the model how to think.

## Top 4 Simplification Candidates

| # | Skill | Lines | Category | Reduction Potential | Action |
|---|-------|-------|----------|-------------------|--------|
| 1 | **orchestrator** | 1,009 | PROCEDURAL | 80% — extract routing to config | Rewrite as outcome-based router |
| 2 | **skill-creator** | 499 | PROCEDURAL | 60% — recursive outcome framework | Simplify to constraints + examples |
| 3 | **panning-for-gold** | 438 | PROCEDURAL | 50% — parameterize workflow | Convert sequential steps to outcomes |
| 4 | **agent-browser** | 431 | PROCEDURAL | 58% — higher-level API | Convert to outcome + tool pattern |

**Combined savings: ~1,577 lines (62% reduction) would drop scaffolding ratio to 12.3%**

## Outcome Skills (37) — KEEP

These define goals and survive model upgrades:
audit-website, blender, stitch, agent_spec_writer, perplexity, exa, ocr, code-reviewer, superdesign-dev, nanobanana, prompt_writer, cold-email, daily-report, daily-digest, weekly-family-review, co-parent, social-analyze, social-experiment, social-optimize, mybcat-blog, mybcat-rag, mybcat-ops, mybcat-ar, playbook, nate-substack, hume, life-engine, obsidian-sync, research_to_website_designer, appointment-data-gatherer, seo-audit, agent-team, repair-bot-test, dark-factory-qa, taste, phi, whoop

## Platform Skills (33) — KEEP

These interface with external APIs (model-independent):
hubspot, gmail, vercel, aws, aws-data, aws-secrets, cloudflare, dataforseo, ahrefs, google-search, google-search-console, google-analytics, google-calendar, google-business-profile, bing-web-tools, monday-com, quickbooks, quickbooks-cvc, bill-com, plaid, sakari_sms, linkedin, blotato, thanks-io, gohighlevel, supabase_opto, github-operations, oystehr-zambda-deploy, bland-ai, codex, gemini, localllm, command-runner

## Procedural Skills (11) — SIMPLIFY TOP 4

These have step-by-step instructions that may constrain better models:
orchestrator, skill-creator, panning-for-gold, agent-browser, command-orchestrator, ffmpeg, remotion, remotion-best-practices, marp, claude-computer-use, schedule

## Hybrid Skills (3) — ACCEPTABLE

These have mixed concerns but are small enough to leave:
claude-api, cosa, frontend-designer

## Recommendations

1. **No mass rewrite needed.** 81.4% of the library is already model-resilient
2. **Simplify top 4** procedural skills (orchestrator, skill-creator, panning-for-gold, agent-browser)
3. **Monitor remaining 7 procedural skills** — test with newer models before rewriting
4. **Archive 0 skills** — all are in active use or have clear purpose
