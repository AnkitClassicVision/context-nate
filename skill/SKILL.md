---
name: nate-context
description: Apply Nate's Newsletter frameworks and prompt kits to MyBCAT with pre-gathered business context. Use this skill when building new features, running audits, creating briefings, or applying any of Nate's operational frameworks (scoring diagnostic, rules file generator, task decomposer, security audit, engineer briefing) to MyBCAT projects.
---

# Nate Context — Apply Frameworks to MyBCAT

This skill provides pre-gathered MyBCAT business context for applying Nate's Newsletter prompt kits without re-querying all MCPs from scratch.

## Quick Reference

| What You Need | Read This First |
|---------------|-----------------|
| MyBCAT company info, team, tech stack | `references/mybcat-business-context.md` |
| Nate's frameworks and patterns | `references/nate-frameworks.md` |
| Universal rules for any MyBCAT repo | `outputs/CLAUDE-UNIVERSAL.md` |
| Previously generated outputs | `outputs/01-*.md` through `outputs/05-*.md` |
| Raw prompt kits to re-run | `prompts/2026-03-16-vibe-coding-safety.md` |

## When to Use

1. **Building a new MyBCAT feature** → Read business context + universal rules before coding
2. **Running a diagnostic** → Use Prompt 1 (Operational Advisor) with pre-gathered scores
3. **Creating rules for a new repo** → Start from `CLAUDE-UNIVERSAL.md` and customize
4. **Decomposing a risky change** → Use Prompt 3 (Task Decomposer) pattern
5. **Auditing security/resilience** → Use Prompt 4 findings as baseline, query AWS MCP for current state
6. **Briefing an external engineer** → Start from Output 05, update with current data

## Adding New Prompt Kits

When Nate publishes a new post with prompts:
1. Use `/nate` skill to fetch the post and extract prompts
2. Save raw prompts to `prompts/YYYY-MM-DD-topic.md`
3. Apply to MyBCAT using business context as answers
4. Save output to `outputs/NN-descriptive-name.md`
5. Update this file's Quick Reference table
