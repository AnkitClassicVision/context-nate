# Prompt 1: Compensating Complexity Audit — MyBCAT Production Systems

**Date:** 2026-04-02
**Framework:** Nate's Newsletter — "A Better Model Can Make Your AI Product Worse" Prompt Kit
**Diagnostic Question Per Layer:**
1. Prompt scaffolding: "Is this instruction here because the model needs it, or because I needed the model to need it?"
2. Retrieval architecture: "How much of my retrieval logic is the model's job?"
3. Hardcoded domain knowledge: "Which of these rules did I write because the model couldn't infer this from context?"
4. Verification placement: "What's the interception rate at each verification stage?"

---

## Overall Summary

| System | Components | Scaffolding+Compensation | Ratio |
|--------|-----------|-------------------------|-------|
| CLAUDE.md Universal Rules | 23 | 9 | **39%** |
| Repair Bot | 11 | 3 | **27%** |
| Sales Agent (12 nodes) | ~120+ | ~48 | **40%** |
| Eye Care Cove Pipeline | ~30 | ~20 | **65%** |
| Hiring Loop | ~15 | ~5 | **30%** |
| **TOTAL** | **~200** | **~85** | **~42%** |

---

## 1A. CLAUDE.md Universal Rules (75 lines, all repos)

**System Overview:** Organizational guardrail document injected as system context for all Claude Code agents working on MyBCAT infrastructure. Functions as both developer onboarding doc and AI behavioral constraint system.

### Component-by-Component Audit

| # | Component | Category | Reasoning | Rec | Deletion Test |
|---|-----------|----------|-----------|-----|---------------|
| 1 | "MyBCAT is a managed back-office..." context block | **OUTCOME LOGIC** | Establishes what the system is and who it serves | KEEP | N/A |
| 2 | "We handle PHI. HIPAA compliance is mandatory" | **CONSTRAINT** | Regulatory requirement, model-independent | KEEP | N/A |
| 3 | "Built primarily with AI coding agents. Founder is not a software engineer" | **OUTCOME LOGIC** | Sets calibration for audience/expertise level | KEEP | N/A |
| 4 | Full architecture list (AWS, Connect, RDS, DynamoDB, Cognito...) | **PROCEDURAL SCAFFOLDING** | Tells the model which services exist — a smarter model with tool access could discover this via AWS MCP | TEST | Give model AWS MCP access + "discover our architecture" and see if it reaches the same conclusions |
| 5 | "Use `secret-store` CLI. Never hardcode." | **CONSTRAINT** | Security practice, model-independent | KEEP | N/A |
| 6 | "CI/CD: GitHub Actions with OIDC auth. Manual trigger" | **CONSTRAINT** | Deployment safety rule | KEEP | N/A |
| 7 | "Python: type hints, f-strings, logging (not print)" | **PROCEDURAL SCAFFOLDING** | Style enforcement a capable model should infer from existing codebase | TEST | Remove and check if model follows existing code patterns via repo analysis |
| 8 | "TypeScript: strict mode. Conventional commits" | **PROCEDURAL SCAFFOLDING** | Same as above — inferable from tsconfig.json + git log | TEST | Same test |
| 9 | "Never log patient names, emails, insurance IDs..." | **CONSTRAINT** | HIPAA requirement | KEEP | N/A |
| 10 | "All DB queries use parameterized statements" | **CONSTRAINT** | Security (SQL injection prevention) | KEEP | N/A |
| 11 | "Do not modify security groups without explicit approval" | **CONSTRAINT** | Scar tissue rule from real incident (5+ DBs exposed) | KEEP | N/A |
| 12 | "Do not create launch-wizard-* SGs" | **COMPENSATING COMPLEXITY** | Compensates for model defaulting to console-style SG creation — a smarter model with Terraform context shouldn't need this | TEST | Remove and verify model uses Terraform by default when given IaC context |
| 13 | "Do not add 0.0.0.0/0 ingress rules" | **CONSTRAINT** | Security, scar tissue from real exposure | KEEP | N/A |
| 14 | "Agents posted insurance passwords in Google Chat" | **COMPENSATING COMPLEXITY** | Explanation of *why* the rule exists — useful for humans but a smarter model doesn't need the backstory to follow the rule | TEST | Replace with just "Never share credentials in chat, comments, or code" and test compliance |
| 15 | "Do not run DB migrations without a snapshot" | **CONSTRAINT** | Data safety, no rollback procedures | KEEP | N/A |
| 16 | "Do not modify DynamoDB Contacts table (1.37M records)" | **CONSTRAINT** | Blast radius control | KEEP | N/A |
| 17 | "If a task will touch more than 3 files, propose a plan" | **PROCEDURAL SCAFFOLDING** | Compensates for model taking too-large actions autonomously — newer models with plan mode may handle this natively | TEST | Remove and test if model naturally proposes plans for large changes |
| 18 | "Assume every table will hold hundreds of thousands of records" | **PROCEDURAL SCAFFOLDING** | Performance design guidance a model should infer from production table sizes | TEST | Remove, give model DB access, see if it adds indexes proactively |
| 19 | "If your agent has been working more than 5 minutes without results, stop" | **COMPENSATING COMPLEXITY** | Compensates for runaway agent loops — a model improvement, not a business rule | TEST | Check if newer model self-terminates on unproductive loops |
| 20 | "Fresh session per logical task" | **COMPENSATING COMPLEXITY** | Context window management workaround | TEST | With 1M context, test if this is still needed |
| 21 | All Security Audit Additions block (8 rules) | **CONSTRAINT** | HIPAA/security requirements, all model-independent | KEEP | N/A |
| 22 | Playbook MCP reference block | **OUTCOME LOGIC** | Points to extended knowledge — outcome-oriented | KEEP | N/A |

### Summary Dashboard
- Outcome Logic: **3** components
- Constraints/Guardrails: **11** components
- Procedural Scaffolding: **5** components
- Compensating Complexity: **4** components
- **Compensating Complexity Ratio: 39%**

### Priority Deletion Tests
1. **Architecture enumeration (item 4):** Test whether a model with AWS MCP tools can discover the stack without being told. High value — this block is ~15% of total tokens.
2. **Code style rules (items 7-8):** Test whether model infers style from existing codebase. Frees ~5% of tokens.
3. **"5-minute timeout" + "fresh session" rules (items 19-20):** Test on a 1M-context model — these were written for shorter context windows.

---

## 1B. Repair Bot (2 prompts in repair_bot.py)

**System Overview:** Two autonomous repair prompts — one for Codex execution, one for planning. Both are tight, constraint-heavy, and well-scoped.

| # | Component | Category | Rec |
|---|-----------|----------|-----|
| 1 | "You are Codex running UNATTENDED on a production Ubuntu VPS" | OUTCOME LOGIC | KEEP |
| 2 | "Goal: diagnose and FIX the issue with minimal changes" | OUTCOME LOGIC | KEEP |
| 3 | "Do NOT print or exfiltrate secrets" | CONSTRAINT | KEEP |
| 4 | "Do NOT delete data or run destructive commands unless absolutely necessary" | CONSTRAINT | KEEP |
| 5 | "Prefer restarting services, fixing config, and small code patches" | PROCEDURAL SCAFFOLDING | TEST — smarter model may find better fix paths |
| 6 | "After changes, verify via the dashboard endpoint" | CONSTRAINT | KEEP |
| 7 | Planning prompt: "You may ONLY propose file edits under these roots: [5 specific paths]" | CONSTRAINT | KEEP — sandboxing is a business rule |
| 8 | "Any file edits must be expressed as a unified diff with ABSOLUTE file paths" | PROCEDURAL SCAFFOLDING | TEST — output format constraint the model may handle better with tool use |
| 9 | JSON output format specification | PROCEDURAL SCAFFOLDING | TEST — structured output may be native |

**Compensating Complexity Ratio: 27%** — Clean, well-scoped prompt. Most is genuine constraints.

---

## 1C. Sales Agent 12-Node Pipeline

**System Overview:** 12 markdown-driven prompt nodes forming an autonomous BDR/SDR pipeline. This is the heaviest system with the most compensating complexity.

| Node | Description | Scaffolding/Compensation Found | Ratio |
|------|-------------|-------------------------------|-------|
| **01 Lead Intake** | Lead prioritization from HubSpot | Priority tier classification rules (hardcoded decision tree) | ~40% |
| **02 Research** | Multi-source intelligence gathering | 4-phase sequential procedure ("Phase 0 then 1 then 2 then 3 then 4") — a smarter model could parallelize and prioritize dynamically | ~55% |
| **03 Qualification** | Binary qualify/disqualify decision | Point-scoring matrix (70-100 = PROCEED, 50-69 = SOFT, etc.) — hardcoded domain logic that may constrain better judgment | ~50% |
| **04 Channel Selection** | Outreach channel routing | Cold/warm eligibility matrix — genuine compliance constraint, but the routing logic is procedural | ~35% |
| **05 LinkedIn** | Connection requests + DMs | "300 characters max", banned words list, "no cross-channel references" — mix of constraints + scaffolding | ~30% |
| **06 Voice (Bland AI)** | Automated phone calls | Full script structure with timing ("Opening 5-8s, Hook 10-15s") — heavy procedural scaffolding for voice bot config | ~60% |
| **07 Postcard** | Physical direct mail | Relatively clean — mostly output format | ~20% |
| **08 Email** | Warm-lead email outreach | Compliance gate (HARD FAIL warm-only) = constraint. But touch-type templates, word counts, signature rules = heavy scaffolding | ~45% |
| **09 SMS** | Text message outreach | Light scaffolding, mostly constraints | ~25% |
| **10 Follow-Up** | Sequence coordination | Timing rules, next-touch logic — procedural | ~50% |
| **11 Booking** | Meeting scheduling | Clean — "always send self-scheduling link" is a constraint | ~15% |
| **12 Record & Report** | CRM documentation | CRM logging format — mostly output specification | ~20% |

### Sales Agent Overall: ~40% compensating complexity

### Highest-Value Deletion Tests
1. **Node 02 Research:** Remove the 4-phase sequential procedure. Give model HubSpot + Gmail + LinkedIn + Web tools and an outcome: "Build a comprehensive research dossier for this lead." Test if it gathers better intel without the forced sequence.
2. **Node 03 Qualification:** Remove the point-scoring matrix. Give model the 3 criteria + example leads with known outcomes. Test if it makes better qualify/disqualify decisions from first principles.
3. **Node 06 Voice:** Remove timing constraints and script structure. Give model the outcome ("brief, honest disclosure call that books meetings") + constraints ("must disclose digital assistant, under 60s") and test quality.

---

## 1D. Eye Care Cove Research-to-Website Pipeline

**System Overview:** 12-phase procedural workflow for deep research + website generation.

**Compensating Complexity Ratio: ~65%** — Most procedurally heavy system. The entire 12-phase sequence is encoded "how" that a capable model could determine dynamically. The design system ("Ethereal Clarity" with specific CSS values) is a genuine constraint.

**Priority Deletion Test:** Give model the outcome ("research this topic thoroughly and build a website presenting findings") + the design system constraints + tools. See if it produces comparable quality without the 12-phase procedure.

---

## 1E. Hiring Loop Orchestrator

**Compensating Complexity Ratio: ~30%** — The graph traversal structure is coordination pattern (good). The "QA gate each with Gemini, fallback Codex" is procedural scaffolding.

---

## Cross-System Observations

1. **Scar tissue rules are the strongest constraints.** Every "Do not X — we had incident Y" rule is a genuine constraint that survives any model upgrade. These are MyBCAT's most valuable prompt components.

2. **Sequential procedures are the weakest.** Every "first do X, then Y, then Z" is a bet against the model figuring out a better order. The sales agent pipeline has the most of these.

3. **The 87+ skills library is unmeasured.** We audited the core system prompts but each of the 87 Claude Code skills likely contains its own scaffolding. A skills audit is the highest-leverage next step.

4. **Verification is unevaluated.** We don't currently measure how often QA runners and verification steps actually catch real errors vs. confirming correct output. This is the key data gap.
