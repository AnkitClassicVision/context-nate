# Prompt 2: Outcome-Based System Prompt Rewriter — MyBCAT Production Systems

**Date:** 2026-04-02
**Framework:** Nate's Newsletter — "A Better Model Can Make Your AI Product Worse" Prompt Kit
**Architecture Pattern:** Outcome Specification + Constraints + Tools + Coordination Pattern

---

## 2A. CLAUDE.md Universal Rules — Rewritten

### Current State
- 75 lines mixing context, constraints, procedures, and incident backstories
- ~1,800 tokens
- Deployed across all MyBCAT repos via symlink

### Rewritten (4-Component Architecture)

---

**OUTCOME SPECIFICATION**

You are building and maintaining AI-powered back-office infrastructure for MyBCAT, a managed call center serving 30+ U.S. optometry practices. Your work directly affects patient data handling, production uptime for 60+ agents, and HIPAA compliance. Success means: code that is secure, performant at scale (100K+ row tables), and deployable via CI/CD without manual intervention. The founder is not a software engineer — your output must be production-ready without expert review.

**CONSTRAINTS AND GUARDRAILS**

*Security (HIPAA — non-negotiable):*
- Never log, display, or store PHI (patient names, emails, insurance IDs, phone numbers, payment info) in plaintext
- All patient-facing endpoints require Cognito auth with MFA (TOTP minimum)
- Row-level security: users see only their tenant's data
- S3 PHI storage requires encryption (KMS preferred). RDS SGs restricted to VPC CIDR
- Rate-limit all public API Gateway endpoints. WAF required on public endpoints
- Never expose internal tools (n8n, Metabase) to 0.0.0.0/0
- No 0.0.0.0/0 ingress on ANY security group
- All DB queries use parameterized statements
- Credentials go in AWS Secrets Manager via `secret-store` CLI. Never in chat, code, comments, or git URLs

*Infrastructure safety:*
- No security group modifications without explicit approval
- No DB migrations without a snapshot
- No DynamoDB Contacts table structure changes without approval (1.37M records)
- No direct pushes to main — branch + PR required
- No infrastructure deploy without `terraform plan` review first
- IaC via Terraform exclusively (no console-created resources)
- Manual CI/CD trigger only — never auto-deploy to prod
- RDS backup retention minimum 35 days
- Bland AI: versioned pathway endpoint only

*Working boundaries:*
- Propose a plan before touching more than 3 files
- State intent before destructive operations (DELETE, DROP, TRUNCATE, SG changes)

**AVAILABLE TOOLS**

- AWS MCP (102 read-only tools for infrastructure inspection)
- MyBCAT Ops MCP (1,126 docs, operational knowledge)
- MyBCAT Playbook MCP (security audits, procedures, onboarding)
- GitHub (CI/CD, repos, PRs)
- Terraform (infrastructure management)
- `secret-store` CLI (secrets management)

---

### Before/After Comparison
- **Original:** 75 lines, ~1,800 tokens
- **Rewritten:** ~45 lines, ~1,100 tokens (**39% reduction**)
- **Procedural steps removed:** 5 (code style rules, architecture enumeration, timeout rule, fresh session rule, index reminder)
- **Constraints preserved:** 11 (all security/HIPAA rules intact)
- **Constraints added:** 0

### Scaffolding Annex (Removed Items)

| Removed Instruction | Likely Failure Mode It Addressed | Test to Determine If Still Needed |
|---------------------|--------------------------------|----------------------------------|
| Architecture enumeration (AWS us-east-1, Connect, RDS, DynamoDB, Cognito, HubSpot, Monday.com, QuickBooks, Bill.com, Stripe, Secrets Manager details) | Model didn't know what services existed in the account | Give model AWS MCP tools, ask it to describe the stack. If it discovers the same architecture, the enumeration is unnecessary |
| "Python: type hints, f-strings, logging (not print)" | Model used print statements, no type hints, string concatenation | Check if model infers coding style from existing codebase patterns when editing files |
| "TypeScript: strict mode. Conventional commits (feat:, fix:, chore:, docs:, ci:)" | Model used loose TypeScript, inconsistent commit messages | Check if model reads tsconfig.json + git log and follows established patterns |
| "If your agent has been working more than 5 minutes without results, stop and check" | Agents ran in circles, burning tokens without progress | Test if newer model (especially with 1M context) self-terminates on unproductive loops |
| "Fresh session per logical task. Do not let sessions run indefinitely" | Context window contamination, session drift | Test with 1M context window — may no longer be necessary |
| "Assume every table will hold hundreds of thousands of records. Add indexes proactively" | Model created unindexed tables, slow queries at scale | Test if model checks actual table sizes (via AWS MCP) before schema design decisions |
| Incident backstories ("We had 5+ DBs exposed to 0.0.0.0/0", "Agents posted insurance passwords in Google Chat") | Added emotional weight to rules so model would take them seriously | Test if model follows "No 0.0.0.0/0 ingress" without the backstory. The rule should stand on its own |

### Migration Notes
- **Risk:** Low. All genuine security constraints preserved verbatim.
- **Test plan:** Deploy to one repo first (e.g., context_nate). Run normal tasks for 3 days. Compare output quality against current CLAUDE.md.
- **Rollback:** Revert symlink to original CLAUDE.md if quality drops.
- **Key watch:** Monitor whether the model still uses parameterized SQL, proper logging, and Terraform-first patterns without the explicit code style rules.

---

## 2B. Sales Agent Node 02 (Research) — Rewritten

### Current State
- ~800 tokens of sequential 4-phase procedure
- Forces: Phase 0 (Pre-Check) → Phase 1 (HubSpot) → Phase 2 (Gmail) → Phase 3 (LinkedIn) → Phase 4 (Web)
- Model locked into fixed order regardless of lead context

### Rewritten (4-Component Architecture)

---

**OUTCOME SPECIFICATION**

Build a comprehensive research dossier for this sales lead. The dossier must contain enough intelligence to personalize outreach across any channel (LinkedIn, email, voice, postcard). A good dossier answers: Who is the decision-maker? Can this practice pay $10K+/month? What specific pain points can we reference? What's our engagement history? "I don't know" is better than fabrication.

**CONSTRAINTS AND GUARDRAILS**

- Pre-check before any research: skip if duplicate in pipeline, active conversation in last 14 days, or timing conflict
- Never fabricate research findings. Mark confidence level on each data point
- HubSpot is source of truth for engagement history
- Do not contact the lead during research phase
- Output must include: persona classification, pain signals with evidence, engagement history, decision-maker identification, and recommended hooks for outreach

**AVAILABLE TOOLS**

- HubSpot CRM (contact history, deal stage, engagement records)
- Gmail (prior email threads)
- LinkedIn (profile, company info, connections)
- Web search (Google reviews, practice website, news, job postings)
- MyBCAT Ops MCP (prior client interactions)

---

### Before/After Comparison
- **Original:** ~800 tokens of sequential procedure
- **Rewritten:** ~250 tokens (**69% reduction**)
- **Key change:** Model decides research order, parallelization, and depth based on what it finds for each lead, rather than following the same sequence for every lead regardless of context
- **What's preserved:** Pre-check gate (compliance), output requirements (dossier contents), no-fabrication constraint

### Scaffolding Annex (Removed Items)

| Removed Instruction | Likely Failure Mode It Addressed | Test to Determine If Still Needed |
|---------------------|--------------------------------|----------------------------------|
| "Phase 0: Pre-Check Gate" as a sequential step | Model would skip duplicate detection and contact leads already in conversation | Test if model runs pre-checks when given the constraint "skip if duplicate or active conversation" without labeling it Phase 0 |
| "Phase 1: HubSpot Context Extraction" with specific field list | Model wouldn't check HubSpot first, or would miss important fields | Test if model naturally checks CRM as part of "build a research dossier" with HubSpot as an available tool |
| "Phase 2: Gmail Engagement History" as forced second step | Model would compose outreach without checking email history | Test if model checks Gmail when told "engagement history" is a required output field |
| "Phase 3: LinkedIn Intelligence Gathering" with specific data points | Model wouldn't go to LinkedIn, or would only grab surface data | Test if model uses LinkedIn tool when told to identify decision-maker and personalize outreach |
| "Phase 4: Web Research" with specific search categories | Model wouldn't check Google reviews, job postings, news | Test if model does web research when told "pain signals with evidence" is required output |

### Migration Notes
- **Risk:** Medium. The sequential procedure ensured thoroughness. An outcome-based version needs to be tested to verify the model still checks all sources.
- **Test plan:** Run 10 leads through both versions. Compare dossier completeness (are all sections filled?) and quality (are pain signals specific and evidence-backed?).
- **Rollback:** Keep original Node 02 as fallback if dossier quality drops.
- **Expected benefit:** Model may discover better research paths (e.g., checking web first for a lead with no HubSpot history, going deep on LinkedIn for a lead with rich profile).

---

## 2C. Sales Agent Node 06 (Voice/Bland AI) — Rewrite Sketch

### Current State
- ~600 tokens of script structure with timing constraints
- "Opening (5-8s) → Hook (10-15s) → Ask (8-10s) → Close (3-5s)"
- Full voicemail template with word count limits

### Rewrite Direction (not full rewrite — needs voice platform testing)

**OUTCOME:** A brief, honest phone call that books discovery meetings. The lead should know it's an AI assistant, hear one specific reason why MyBCAT is relevant to them, and get a clear way to book a call with Ankit.

**CONSTRAINTS:** Must disclose digital assistant identity upfront. Live call under 100 words. Voicemail under 60 words. No pricing, no feature lists, no pretending to be human. Graceful exit for uninterested leads.

**Note:** Bland AI voice bots have platform-specific constraints (pathway structure, edge labels, timing) that may require some procedural scaffolding regardless of model capability. This rewrite should be tested in the Bland AI pathway editor, not just as a prompt.

---

## Summary: Rewrite Priorities

| System | Current Tokens | Rewritten Tokens | Reduction | Priority |
|--------|---------------|-----------------|-----------|----------|
| CLAUDE.md | ~1,800 | ~1,100 | **39%** | **P1** — deploy this week |
| Sales Node 02 | ~800 | ~250 | **69%** | **P2** — A/B test next 2 weeks |
| Sales Node 03 | ~700 | ~200 (est.) | ~71% | **P3** — after Node 02 validates |
| Sales Node 06 | ~600 | ~300 (est.) | ~50% | **P4** — requires Bland AI platform testing |
| Eye Care Cove | ~2,000 | ~600 (est.) | ~70% | **P5** — lower priority, less frequent use |
