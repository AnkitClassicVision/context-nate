---
name: playbook
description: Access MyBCAT operational playbook - security audits, business context, procedures, rules, onboarding materials, and Nate frameworks. Use when building features, running audits, onboarding engineers, decomposing tasks, or checking operational guidelines.
---

# Playbook

Use this skill to pull the right MyBCAT operating context before making changes with meaningful blast radius.

## MCP Tools

| Tool | Use It For | Returns |
|------|------------|---------|
| `search_playbook(query, category?, limit?)` | Semantic search across playbook docs when you know the topic but not the filename | Ranked matches with `title`, `category`, `filename`, `score`, `excerpt` |
| `get_playbook_doc(filename)` | Full retrieval when you know the filename or close partial match | Full document with `title`, `category`, `filename`, `created_date`, `content_text` |
| `list_playbook(category?)` | Browsing available playbook material by category | Document index with `title`, `category`, `filename`, `created_date` |

## Recommended Workflow

### 1. Build Features With Context

1. Start with `search_playbook` for the system, workflow, or risk area you are touching.
2. Open the most relevant files with `get_playbook_doc`.
3. Read the universal rules before coding if the work affects infrastructure, security, auth, data, or deployment.
4. Keep blast radius small and encode any new scar tissue into persistent guidance.

### 2. Decompose Risky Work

1. Read `/mnt/d_drive/repos/context_nate/outputs/03-task-decomposer.md`.
2. Break the change into narrow tasks with clear ownership, verification, and rollback boundaries.
3. Prefer steps that can be tested independently and committed separately.
4. Escalate when the task crosses infra, auth, schema, or PHI boundaries.

### 3. Run Audits

1. Read `/mnt/d_drive/repos/context_nate/outputs/04-security-resilience-audit.md`.
2. Search for the current system or repo in the playbook MCP.
3. Compare the requested change against existing scar tissue rules and known incidents.
4. Call out unresolved risks before implementation, especially public exposure, auth gaps, weak rollback, or PHI handling.

### 4. Onboard Engineers

1. Read `/mnt/d_drive/repos/context_nate/outputs/05-engineer-briefing.md`.
2. Read `/mnt/d_drive/repos/context_nate/outputs/CLAUDE-UNIVERSAL.md`.
3. Pull supporting business context or framework docs as needed.
4. Brief the engineer on constraints, not just goals.

## Local File References

| File | Purpose |
|------|---------|
| `/mnt/d_drive/repos/context_nate/outputs/CLAUDE-UNIVERSAL.md` | Universal repo rules for MyBCAT work |
| `/mnt/d_drive/repos/context_nate/outputs/01-operational-advisor-diagnostic.md` | Operating model and current-state diagnostic |
| `/mnt/d_drive/repos/context_nate/outputs/02-rules-file-generator.md` | Rule patterns to encode into persistent instructions |
| `/mnt/d_drive/repos/context_nate/outputs/03-task-decomposer.md` | Change decomposition and blast-radius reduction |
| `/mnt/d_drive/repos/context_nate/outputs/04-security-resilience-audit.md` | Security and resilience baseline |
| `/mnt/d_drive/repos/context_nate/outputs/05-engineer-briefing.md` | Engineer onboarding and project briefing |
| `/mnt/d_drive/repos/context_nate/references/mybcat-business-context.md` | Business model, org, tech stack, and current priorities |
| `/mnt/d_drive/repos/context_nate/references/nate-frameworks.md` | Nate framework summaries and key concepts |
| `/mnt/d_drive/repos/context_nate/prompts/2026-03-16-vibe-coding-safety.md` | Source prompts used to generate the current outputs |

## Key Nate Concepts

### Blast Radius

Keep tasks narrow enough that failure is observable, reversible, and cheap. Prefer small edits, tight scopes, and explicit verification.

### Scar Tissue Rules

Rules exist because the team already paid for the lesson. Preserve them, extend them when new incidents happen, and do not treat them as optional style guidance.

### 80-20 Threshold

Use AI to get to the first 80% quickly. Reserve expert judgment for the last 20% where business context, security, and operational reality matter most.

### Rejection > Prompting

Corrections compound more than prompts. When you reject bad output, explain why and encode the constraint so the next attempt starts from a better baseline.

### Harness > Model

Execution quality depends more on orchestration, rules, checks, and verification loops than on swapping one model for another. Improve the harness before chasing model changes.
