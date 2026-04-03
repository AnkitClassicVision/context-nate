# 06 — Token Usage Findings (Nate's Compensating Complexity Audit)

**Date:** 2026-04-02
**Source Post:** [Every workaround you built for the last model is now breaking the next one](https://natesnewsletter.substack.com/p/anthropic-just-built-a-model-that) (April 1, 2026)
**Prompt Kit:** "A Better Model Can Make Your AI Product Worse" — 4-prompt diagnostic kit

## Summary

Applied all 4 prompts from Nate's kit to MyBCAT's production AI systems:

| File | Prompt | Key Finding |
|------|--------|-------------|
| `01-compensating-complexity-audit.md` | Compensating Complexity Audit | **42% of ~200 prompt components are scaffolding or compensating complexity** |
| `02-outcome-based-rewriter.md` | Outcome-Based System Prompt Rewriter | **CLAUDE.md can shrink 39%**; Sales Agent Node 02 can shrink 69% |
| `03-org-level-dependency-map.md` | Org-Level Model Dependency Map | **52% of roles/processes have model-dependent components**; 60+ agents = highest Klarna risk |
| `04-step-change-readiness-plan.md` | Step-Change Readiness Plan | **3-phase action plan** starting with CLAUDE.md deployment + interception logging |

## Systems Audited

1. **CLAUDE.md Universal Rules** (75 lines, deployed across all repos)
2. **Agent-Repair repair_bot.py** (2 prompts — Codex repair + planning)
3. **Sales Agent 12-node pipeline** (12 distinct role prompts)
4. **Eye Care Cove Research-to-Website pipeline** (12-phase workflow)
5. **Hiring Loop Orchestrator** (graph traversal candidate evaluation)

## Headline Numbers

- **42%** compensating complexity ratio across all production prompts
- **39%** token reduction possible in CLAUDE.md (rewrite ready)
- **69%** token reduction possible in Sales Agent Node 02 (rewrite ready)
- **52%** of org roles/processes have model-dependent components
- **87+ skills** need outcome-vs-procedure audit
- **60+ agents** = highest Klarna risk (voice AI targeting core job function)
