# Soni Handoff — HubSpot Daily 2 Retrieval-Contract Eval

**Created:** 2026-05-13  
**Target repo:** `/mnt/d_drive/repos/hubspot-daily-2`  
**Evaluator:** Soni  
**Mode:** local/read-only evaluation first. No live HubSpot, Gmail, LinkedIn, Fathom, CRM, calendar, SMS, or outbound API calls.  
**Classification:** internal repo/workflow readiness eval for sales/outreach agent autonomy.  

## Source set

### Nate source

- **Post:** “Your AI agent is rediscovering 85% of its context every run. Here's the architecture fix (+ Contract Spec, Failure Triage, and Stack ADR)”
- **Date:** 2026-05-13
- **URL:** https://natesnewsletter.substack.com/p/rag-agents-knowledge-layer-architecture
- **Prompt page:** https://promptkit.natebjones.com/20260508_639_promptkit_2
- **Prompt count found:** 3
  1. Retrieval Contract Spec
  2. Retrieval Failure Triage
  3. Retrieval Stack ADR
- **Relevant linked sources pulled into the lens:** Pinecone Nexus / KnowQL, PageIndex document-structure retrieval, SAP/Dremio governed data layer, SAP/Prior Labs tabular foundation models, Microsoft GraphRAG, Chroma Context Rot, Cognition context-engineering warning, Anthropic multi-agent research system, LangChain context engineering.

### HubSpot Daily 2 source files

Start with these, in order:

1. `CLAUDE.md`
2. `docs/evals/mybcat-ai-assisted-code-quality-eval-pack-v0.1.md`
3. `docs/evals/hubspot-daily-2-quality-eval-application-2026-05-08.md`
4. `reference/automation-rules.md`
5. `commands/daily.md`
6. `scripts/daily_orchestrator.py`
7. `scripts/gap_sync.py`
8. `scripts/gmail_context_sync.py`
9. `scripts/linkedin_context_sync.py`
10. `scripts/lib/context_pack.py`
11. `scripts/hermes_sales_mirror_scan.py`
12. `scripts/validate_email_draft.py`
13. Relevant tests under `tests/`

Do **not** inspect raw databases, live API responses, contact exports, or state/report artifacts containing identities unless Ankit explicitly approves a redacted data review.

## Why Nate’s post matters for this repo

Nate’s 2026-05-13 argument is that production agents are not mostly failing because “vector search is bad.” They fail because the system does not assemble the exact context bundle the agent needs **before acting**:

- the work object,
- the controlling source of truth,
- permissions/scope,
- current records,
- prior decisions,
- source trail/provenance,
- and what state the agent is allowed to write back.

That maps directly to HubSpot Daily 2. This repo is not just “a sales script.” It is a daily context-assembly and action-gating system for outbound/re-engagement workflows.

The eval question should therefore be:

> Does HubSpot Daily 2 assemble the right source-backed, permission-scoped, provenance-preserving context bundle before draft/write actions, and is that contract tested well enough to justify moving beyond local/draft-only mode?

Baseline from the existing eval: **`allow_local_only`; `block_autonomous`** until compile/test/runtime and autonomy-safety blockers are fixed.

## Non-negotiable safety lane for Soni

Allowed:

- Read code/docs/tests locally.
- Run local static checks and unit tests that do not call live services.
- Produce a source-backed eval report.
- Recommend fixes.

Blocked without explicit Ankit approval:

- HubSpot writes or property patches.
- Gmail drafts, sends, or BCC use.
- LinkedIn/SMS sends.
- Live contact enrichment.
- Raw `knowledge.db` inspection.
- Outputting names, emails, phones, message bodies, raw IDs, tokens, secrets, or private URLs.

## Existing baseline to preserve

The existing quality eval found:

- Verdict: `allow_local_only`; `block_autonomous`.
- Full pytest failed during collection due to `scripts/gap_sync.py` syntax error.
- Compile check failed in `scripts/daily_orchestrator.py` and `scripts/gap_sync.py`.
- No clean root dependency/runtime manifest was found.
- Required fixes included compileall, full pytest, dependency manifest, artifact leak scan tests, bounded-scan tests, replay/idempotency tests, and a run-card/eval-result artifact.

Soni should treat that as the starting hypothesis and verify whether it is still true.

---

# Copy/paste prompt for Soni

```text
You are evaluating /mnt/d_drive/repos/hubspot-daily-2 for MyBCAT.

Use Nate’s 2026-05-13 “retrieval contract” framing and the repo’s existing eval pack.

Primary source docs:
- docs/evals/mybcat-ai-assisted-code-quality-eval-pack-v0.1.md
- docs/evals/hubspot-daily-2-quality-eval-application-2026-05-08.md
- CLAUDE.md
- reference/automation-rules.md
- commands/daily.md

Mode:
- Local/read-only only.
- Do not call HubSpot, Gmail, LinkedIn, Fathom, SMS, calendar, or any external API.
- Do not inspect or print raw contact data, message bodies, phone numbers, emails, tokens, secrets, OAuth data, or raw database rows.
- Use file paths and line numbers for evidence.
- Mark unknowns as gaps. Do not guess.

Task:
Evaluate whether HubSpot Daily 2 has a sufficient retrieval/context-assembly contract to support sales outreach actions safely.

Answer in five sections:

1. Verdict
Use one of:
- allow_local_only
- allow_manual_approved_writes
- block_autonomous
- allow_autonomous

2. Retrieval Contract Spec
Use these seven dimensions:
- Work object: what named business object the agent acts on per task.
- Retrieval units required: exact artifacts needed before action, e.g. contact record, company/practice context, Gmail thread, HubSpot task, deal, gap alert, OB_mybcat memory, domain scope, suppression/bounce/opt-out state, Fathom check, prior run state.
- Authoritative source per unit: named source of truth for each unit.
- Permission/scope checks: who/what is eligible, and what fails closed.
- Provenance required: what source trail a human reviewer must be able to reconstruct.
- Compiled context candidates: what should be assembled once per run vs per contact, with freshness/invalidation rules.
- Write-back contract: what the agent may write back, in which mode, with owner, approval, confidence, source hash, and rollback path.

3. Retrieval Failure Triage
Classify current or likely failures against Nate’s failure modes:
- wrong retrieval unit
- non-authoritative source
- missing permissions check
- missing provenance
- context rebuilding
- stale/overfull context or context rot
- unsafe/missing write-back contract
Also say when a blocker is not a retrieval failure, e.g. syntax/test/dependency failure.
For each finding: evidence, minimum fix, what NOT to rebuild, verification.

4. MyBCAT Eval Pack Scorecard
Score Q1-Q12 from docs/evals/mybcat-ai-assisted-code-quality-eval-pack-v0.1.md:
- 0 blocker
- 1 weak
- 2 acceptable with watchouts
- 3 strong
Include source evidence for every score.

5. ADR Recommendation
Write a short ADR for the next architecture decision.
Candidate decision to evaluate:
“Add a deterministic Daily Context Pack Contract + Run Card as a hard pre-action gate before any draft, HubSpot write, or Gmail action.”
Compare against at least two real alternatives:
- Status quo: CLAUDE.md rules plus ad hoc script checks.
- Pure vector/RAG expansion.
- GraphRAG/knowledge graph first.
- Manual-only review with no retrieval-contract change.
Include consequences, rollback plan, and required tests.

Final output must include:
- Mandatory blockers found
- Tests run and results
- Allowed next autonomy level
- Blocked next autonomy level
- Required fixes before promotion
- Evidence gaps
```

---

# Expected Soni output shape

## 1. Verdict

Recommended starting default unless verified otherwise:

- `allow_local_only`
- `block_autonomous`

Reason: existing eval shows compile/test blockers and missing runtime/dependency contract. Nate’s retrieval lens adds another promotion gate: the repo must prove it assembles the right context bundle before any action, not merely that it has many context sources.

## 2. Retrieval Contract checks to force

For each daily/outreach task, Soni should verify whether the repo can answer:

- **Work object:** Is the unit of action a contact, company/practice, task, deal, gap alert, draft, or run?
- **Required retrieval units:** Which artifacts must be present before the first word of a draft?
- **Authority:** Which system wins when HubSpot, Gmail, memory, old reports, and local state disagree?
- **Freshness:** What is the stale tolerance per unit?
- **Eligibility:** Which categories fail closed before LLM/writer steps?
- **Provenance:** Can a reviewer reconstruct why an action happened without seeing private message bodies?
- **Write-back:** What state gets written after the run, and how is it labeled as observed/inferred/user-confirmed/stale/rejected/authoritative?

## 3. Likely retrieval-contract gaps to test

These are hypotheses, not findings, until Soni cites source lines/tests:

- A written pre-draft context gate exists, but Soni must verify it is mechanically enforced in code/tests.
- Multiple context sources exist, but Soni must verify source-of-truth precedence when sources conflict.
- Reports/traces exist, but Soni must verify they are sanitized and replayable without identities/message bodies.
- Daily sync state exists, but Soni must verify stale-state invalidation and safe resume behavior.
- Context may be rebuilt across runs; Soni should look for source hashes, compiled context packs, and cache invalidation rules.
- `memory.md` and OB_mybcat context should be evidence, not instruction-grade truth, unless promoted through an approved rule path.

## 4. What Nate’s lens rules out

Soni should explicitly say the eval rules out:

1. **Naive top-K RAG as proof of readiness.** The agent needs structured records, eligibility gates, current threads, state, and source authority, not just semantically relevant text.
2. **Task-subject-only drafting.** A HubSpot task is not enough context to draft outreach.
3. **Aggregate report proof.** Counts and summaries cannot prove contact-level eligibility or message correctness.
4. **Memory-as-policy.** Prior memory can inform review, but controlling policy must be explicit and current.
5. **Autonomous writeback without run-card evidence.** Every write-capable path needs mode, owner, approval, idempotency key, source hash, rollback/compensation path, and sanitized evidence.

## 5. Minimal fix direction if gaps remain

Do not jump straight to GraphRAG, a new vector database, or a larger agent swarm.

Minimum architecture fix to evaluate first:

- Define `DailyContextPackV1` as a typed artifact.
- Define required retrieval units per work object.
- Add authoritative-source precedence rules.
- Add freshness/invalidation rules.
- Add eligibility/suppression/bounce/duplicate gates before LLM writing.
- Add sanitized provenance ledger.
- Add run-card with mode, owner, reviewer, source hashes, output counts, approval state, and rollback path.
- Add replay/idempotency and artifact-leak tests.
- Keep the repo `local/draft-only` until compileall, pytest, and eval-pack gates are green.

## 6. Suggested local-only commands

Run only if the repo environment is safe and dependencies are available:

```bash
git status --short
python -m compileall -q scripts tests
python -m pytest -q
python -m pytest tests/test_phase_4_5.py tests/test_codex_conductor.py tests/lib/test_context_pack.py tests/test_migrations.py -q
```

Do not run commands that require live HubSpot/Gmail credentials or produce real drafts/sends/writes.

## 7. Promotion bar

HubSpot Daily 2 should not advance beyond local/draft-only unless all are true:

- Compile check is green.
- Full relevant test suite is green or exclusions are documented with owner/date.
- Dependency/runtime manifest exists.
- Daily Context Pack contract is explicit and typed.
- Every required retrieval unit has a named authoritative source and freshness rule.
- Permission/scope/suppression gates fail closed before draft/write.
- Output is traceable to sanitized source evidence.
- Replay/idempotency tests pass for every writer path.
- Artifact leak scan passes.
- Human owner/approver/escalation path is mechanically encoded.
- Ankit approves any move beyond local/draft-only.
