# Compensating Complexity — Test & Implement Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Test each finding from the Nate "Compensating Complexity" audit against MyBCAT's production systems, then implement changes where tests show improvement or no regression.

**Architecture:** Six independent test-then-implement tracks, each with a measurement phase followed by a decision gate. No track depends on another — all can run in parallel. Each track follows the pattern: instrument → measure baseline → test change → compare → implement or revert.

**Tech Stack:** Python 3.12, CloudWatch metrics, JSONL logging, Markdown node files, Bash scripting

**Source Findings:** `/mnt/d_drive/repos/context_nate/outputs/06-token-usage-findings/`

---

## File Structure

```
Modified files:
  /mnt/d_drive/repos/agent-repair/repair_bot.py           — Task 1: Add interception metrics
  /mnt/d_drive/repos/sales_agent/qa/qa_runner.py           — Task 2: Add interception metrics
  /mnt/d_drive/repos/.claude/CLAUDE.md                     — Task 3: Deploy lean version
  /mnt/d_drive/repos/sales_agent/nodes/02_research.md      — Task 4: Outcome-based rewrite
  /mnt/d_drive/repos/sales_agent/nodes/03_qualification.md — Task 5: Outcome-based rewrite

New files:
  /mnt/d_drive/repos/agent-repair/metrics/interception_log.py        — Task 1: Metrics helper
  /mnt/d_drive/repos/sales_agent/qa/interception_metrics.py          — Task 2: Metrics helper
  /mnt/d_drive/repos/.claude/CLAUDE-lean.md                          — Task 3: Lean version for testing
  /mnt/d_drive/repos/sales_agent/nodes/02_research_outcome.md        — Task 4: A/B version
  /mnt/d_drive/repos/sales_agent/nodes/03_qualification_outcome.md   — Task 5: A/B version
  /mnt/d_drive/repos/context_nate/outputs/06-token-usage-findings/skills-audit.md — Task 6: Audit
```

---

### Task 1: Repair Bot Interception Logging

**Purpose:** Measure how often repair_bot.py actually fixes something vs. confirms healthy. This tells us whether the verification layer is catching real issues or rubber-stamping.

**Files:**
- Create: `/mnt/d_drive/repos/agent-repair/metrics/interception_log.py`
- Modify: `/mnt/d_drive/repos/agent-repair/repair_bot.py` (around lines 2484-2496, the auto_fix decision point)

- [ ] **Step 1: Create the metrics helper module**

```python
# /mnt/d_drive/repos/agent-repair/metrics/interception_log.py
"""Lightweight interception metrics for repair bot.

Tracks action_taken vs no_action_needed per run.
Writes to JSONL file + emits CloudWatch metric if boto3 available.
"""
import json
import logging
from datetime import datetime, timezone
from pathlib import Path

log = logging.getLogger(__name__)

METRICS_DIR = Path(__file__).parent / "data"
METRICS_FILE = METRICS_DIR / "interception_metrics.jsonl"


def record_interception(
    issue_id: str,
    action_taken: bool,
    action_type: str | None = None,
    result: str | None = None,
    severity: str | None = None,
) -> None:
    """Record whether the repair bot took action or confirmed healthy.

    Args:
        issue_id: Unique identifier for the issue evaluated.
        action_taken: True if bot actually fixed something, False if no action needed.
        action_type: What kind of fix (restart, config_change, code_patch, escalate).
        result: Outcome of the action (success, failed, skipped).
        severity: Issue severity (critical, high, medium, low).
    """
    METRICS_DIR.mkdir(parents=True, exist_ok=True)

    entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "issue_id": issue_id,
        "action_taken": action_taken,
        "action_type": action_type,
        "result": result,
        "severity": severity,
    }

    with open(METRICS_FILE, "a") as f:
        f.write(json.dumps(entry) + "\n")

    log.info(
        "interception_metric: action_taken=%s action_type=%s result=%s issue=%s",
        action_taken,
        action_type,
        result,
        issue_id,
    )

    _emit_cloudwatch(action_taken)


def _emit_cloudwatch(action_taken: bool) -> None:
    """Best-effort CloudWatch metric emission."""
    try:
        import boto3

        cw = boto3.client("cloudwatch", region_name="us-east-1")
        cw.put_metric_data(
            Namespace="MyBCAT/RepairBot",
            MetricData=[
                {
                    "MetricName": "ActionTaken" if action_taken else "NoActionNeeded",
                    "Value": 1,
                    "Unit": "Count",
                }
            ],
        )
    except Exception as e:
        log.debug("CloudWatch metric emission failed (non-critical): %s", e)


def get_summary(days: int = 30) -> dict:
    """Read metrics file and return summary counts."""
    if not METRICS_FILE.exists():
        return {"total": 0, "action_taken": 0, "no_action": 0, "ratio": "N/A"}

    total = 0
    action_taken = 0
    cutoff = datetime.now(timezone.utc).timestamp() - (days * 86400)

    with open(METRICS_FILE) as f:
        for line in f:
            entry = json.loads(line.strip())
            ts = datetime.fromisoformat(entry["timestamp"]).timestamp()
            if ts >= cutoff:
                total += 1
                if entry["action_taken"]:
                    action_taken += 1

    no_action = total - action_taken
    ratio = f"{(no_action / total * 100):.1f}%" if total > 0 else "N/A"

    return {
        "total": total,
        "action_taken": action_taken,
        "no_action": no_action,
        "confirmation_ratio": ratio,
    }
```

- [ ] **Step 2: Verify the module imports cleanly**

Run: `cd /mnt/d_drive/repos/agent-repair && python3 -c "from metrics.interception_log import record_interception, get_summary; print('OK')"`
Expected: `OK`

- [ ] **Step 3: Add interception recording to repair_bot.py at the fix decision point**

Find the section around line 2484 in `/mnt/d_drive/repos/agent-repair/repair_bot.py` where `auto_fix()` is called. Add metrics recording after the fix attempt and at each skip/escalation path.

Add this import near the top of repair_bot.py (with the other imports):
```python
from metrics.interception_log import record_interception
```

At the auto_fix call site (around line 2484), after `success, detail = auto_fix(issue, state)`:
```python
record_interception(
    issue_id=h,
    action_taken=True,
    action_type="auto_fix",
    result="success" if success else "failed",
    severity=issue.get("severity", "unknown"),
)
```

At each escalation/skip path (cooldown skip ~line 2476, loop guard ~line 2457, hard cap ~line 2436, auto_fix disabled ~line 2481):
```python
record_interception(
    issue_id=h,
    action_taken=False,
    action_type="skipped_cooldown",  # or "escalated_loop_guard", "escalated_hard_cap", "monitoring_only"
    result="skipped",
    severity=issue.get("severity", "unknown"),
)
```

- [ ] **Step 4: Test with a dry run**

Run: `cd /mnt/d_drive/repos/agent-repair && python3 -c "
from metrics.interception_log import record_interception, get_summary
record_interception('test-001', True, 'auto_fix', 'success', 'medium')
record_interception('test-002', False, 'monitoring_only', 'skipped', 'low')
record_interception('test-003', False, 'skipped_cooldown', 'skipped', 'low')
print(get_summary(days=1))
"`
Expected: `{'total': 3, 'action_taken': 1, 'no_action': 2, 'confirmation_ratio': '66.7%'}`

- [ ] **Step 5: Clean up test data and commit**

```bash
rm -f /mnt/d_drive/repos/agent-repair/metrics/data/interception_metrics.jsonl
cd /mnt/d_drive/repos/agent-repair
git add metrics/interception_log.py repair_bot.py
git commit -m "feat: add interception metrics to repair bot

Tracks action_taken vs no_action_needed per run for compensating
complexity audit. Writes to JSONL + CloudWatch."
```

- [ ] **Step 6: Decision gate (after 7 days of production data)**

Run: `cd /mnt/d_drive/repos/agent-repair && python3 -c "from metrics.interception_log import get_summary; import json; print(json.dumps(get_summary(7), indent=2))"`

**Decision criteria:**
- If `confirmation_ratio` > 90%: The repair bot is mostly confirming healthy systems. Consider reducing check frequency or simplifying the prompt.
- If `confirmation_ratio` 50-90%: Healthy mix. Keep current verification level.
- If `confirmation_ratio` < 50%: The bot is catching real issues frequently. Keep or strengthen verification.

---

### Task 2: QA Runner Interception Logging

**Purpose:** Measure how often qa_runner.py changes AI output vs. rubber-stamps it. This tells us if the QA layer is catching real errors worth the latency cost.

**Files:**
- Create: `/mnt/d_drive/repos/sales_agent/qa/interception_metrics.py`
- Modify: `/mnt/d_drive/repos/sales_agent/qa/qa_runner.py` (around lines 393-423, the `_log_evaluation()` function)

- [ ] **Step 1: Create QA interception metrics helper**

```python
# /mnt/d_drive/repos/sales_agent/qa/interception_metrics.py
"""QA interception metrics — tracks pass vs. fail rates and what QA actually catches."""
import json
import logging
from datetime import datetime, timezone
from pathlib import Path

log = logging.getLogger(__name__)

METRICS_DIR = Path(__file__).parent / "metrics_data"
METRICS_FILE = METRICS_DIR / "qa_interception.jsonl"


def record_qa_verdict(
    run_id: str,
    contact_id: str,
    node: str,
    channel: str,
    verdict: str,
    overall_score: int,
    failures: list[dict],
    attempt: int,
    execution_time_ms: int,
) -> None:
    """Record QA verdict with interception classification.

    Classifies each run as:
    - PASSED_CLEAN: QA approved, no issues found (rubber stamp)
    - PASSED_WITH_WARNINGS: QA approved but flagged minor issues
    - FAILED_CAUGHT_ERROR: QA caught a real problem (the value-add)
    """
    METRICS_DIR.mkdir(parents=True, exist_ok=True)

    critical_failures = [f for f in failures if f.get("severity") == "critical"]
    high_failures = [f for f in failures if f.get("severity") == "high"]

    if verdict == "PASS" and not failures:
        interception_type = "PASSED_CLEAN"
    elif verdict == "PASS" and failures:
        interception_type = "PASSED_WITH_WARNINGS"
    else:
        interception_type = "FAILED_CAUGHT_ERROR"

    entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "run_id": run_id,
        "contact_id": contact_id,
        "node": node,
        "channel": channel,
        "verdict": verdict,
        "interception_type": interception_type,
        "overall_score": overall_score,
        "failure_count": len(failures),
        "critical_failures": len(critical_failures),
        "high_failures": len(high_failures),
        "attempt": attempt,
        "execution_time_ms": execution_time_ms,
    }

    with open(METRICS_FILE, "a") as f:
        f.write(json.dumps(entry) + "\n")

    log.info(
        "qa_interception: type=%s verdict=%s score=%d failures=%d node=%s contact=%s",
        interception_type,
        verdict,
        overall_score,
        len(failures),
        node,
        contact_id,
    )


def get_summary(days: int = 30) -> dict:
    """Return interception summary over the given period."""
    if not METRICS_FILE.exists():
        return {"total": 0, "passed_clean": 0, "passed_warnings": 0, "failed_caught": 0}

    total = passed_clean = passed_warnings = failed_caught = 0
    total_time_ms = 0
    cutoff = datetime.now(timezone.utc).timestamp() - (days * 86400)

    with open(METRICS_FILE) as f:
        for line in f:
            if not line.strip():
                continue
            entry = json.loads(line.strip())
            ts = datetime.fromisoformat(entry["timestamp"]).timestamp()
            if ts >= cutoff:
                total += 1
                total_time_ms += entry.get("execution_time_ms", 0)
                match entry["interception_type"]:
                    case "PASSED_CLEAN":
                        passed_clean += 1
                    case "PASSED_WITH_WARNINGS":
                        passed_warnings += 1
                    case "FAILED_CAUGHT_ERROR":
                        failed_caught += 1

    rubber_stamp_rate = f"{(passed_clean / total * 100):.1f}%" if total > 0 else "N/A"
    catch_rate = f"{(failed_caught / total * 100):.1f}%" if total > 0 else "N/A"
    avg_time = f"{(total_time_ms / total):.0f}ms" if total > 0 else "N/A"

    return {
        "total": total,
        "passed_clean": passed_clean,
        "passed_warnings": passed_warnings,
        "failed_caught": failed_caught,
        "rubber_stamp_rate": rubber_stamp_rate,
        "catch_rate": catch_rate,
        "avg_execution_time": avg_time,
    }
```

- [ ] **Step 2: Verify the module imports cleanly**

Run: `cd /mnt/d_drive/repos/sales_agent && python3 -c "from qa.interception_metrics import record_qa_verdict, get_summary; print('OK')"`
Expected: `OK`

- [ ] **Step 3: Wire interception recording into qa_runner.py**

In `/mnt/d_drive/repos/sales_agent/qa/qa_runner.py`, add this import near the top:
```python
from qa.interception_metrics import record_qa_verdict
```

In the `_log_evaluation()` function (around line 393), after the existing JSONL write, add:
```python
record_qa_verdict(
    run_id=run_id,
    contact_id=contact_id,
    node=node,
    channel=channel,
    verdict=result["verdict"],
    overall_score=result["overall_score"],
    failures=result.get("failures", []),
    attempt=attempt,
    execution_time_ms=elapsed_ms,
)
```

- [ ] **Step 4: Test with synthetic data**

Run: `cd /mnt/d_drive/repos/sales_agent && python3 -c "
from qa.interception_metrics import record_qa_verdict, get_summary
record_qa_verdict('r1', 'c1', '05_linkedin', 'linkedin', 'PASS', 88, [], 1, 320)
record_qa_verdict('r2', 'c2', '08_email', 'email', 'FAIL', 42, [{'severity': 'critical', 'criterion': 'compliance'}], 1, 450)
record_qa_verdict('r3', 'c3', '05_linkedin', 'linkedin', 'PASS', 91, [], 1, 280)
print(get_summary(1))
"`
Expected: `{'total': 3, 'passed_clean': 2, 'passed_warnings': 0, 'failed_caught': 1, 'rubber_stamp_rate': '66.7%', 'catch_rate': '33.3%', 'avg_execution_time': '350ms'}`

- [ ] **Step 5: Clean up test data and commit**

```bash
rm -f /mnt/d_drive/repos/sales_agent/qa/metrics_data/qa_interception.jsonl
cd /mnt/d_drive/repos/sales_agent
git add qa/interception_metrics.py qa/qa_runner.py
git commit -m "feat: add interception metrics to QA runner

Tracks PASSED_CLEAN vs FAILED_CAUGHT_ERROR rates for compensating
complexity audit. Writes to JSONL with summary function."
```

- [ ] **Step 6: Decision gate (after 7 days of production data)**

Run: `cd /mnt/d_drive/repos/sales_agent && python3 -c "from qa.interception_metrics import get_summary; import json; print(json.dumps(get_summary(7), indent=2))"`

**Decision criteria:**
- If `rubber_stamp_rate` > 90%: QA is mostly confirming correct output. Consider: move QA to end-of-pipeline only (one check instead of per-node), or reduce to spot-checking.
- If `rubber_stamp_rate` 70-90%: QA catches enough to justify its cost. Keep but consider reducing frequency.
- If `rubber_stamp_rate` < 70%: QA is catching real problems. Keep at current level.
- If `avg_execution_time` > 500ms: QA is adding significant latency. Consider async QA for non-critical channels.

---

### Task 3: CLAUDE.md Lean Version Test

**Purpose:** Test whether removing 39% of CLAUDE.md (scaffolding + compensating complexity) causes any quality regression. If not, deploy the lean version across all repos.

**Files:**
- Create: `/mnt/d_drive/repos/.claude/CLAUDE-lean.md`
- Modify: `/mnt/d_drive/repos/.claude/CLAUDE.md` (only if test passes)

- [ ] **Step 1: Create the lean CLAUDE.md**

Write `/mnt/d_drive/repos/.claude/CLAUDE-lean.md` with the rewritten content from `06-token-usage-findings/02-outcome-based-rewriter.md`. The full content is the "Rewritten (4-Component Architecture)" section:

```markdown
<!-- MYBCAT-GUIDELINES-LEAN-START -->
<!-- Lean version: scaffolding removed per compensating complexity audit 2026-04-02 -->
<!-- Source: context_nate/outputs/06-token-usage-findings/02-outcome-based-rewriter.md -->

## MyBCAT Universal Rules (Lean)

### Outcome
You are building and maintaining AI-powered back-office infrastructure for MyBCAT, a managed call center serving 30+ U.S. optometry practices. Your work directly affects patient data handling, production uptime for 60+ agents, and HIPAA compliance. Success means: code that is secure, performant at scale (100K+ row tables), and deployable via CI/CD without manual intervention. The founder is not a software engineer — your output must be production-ready without expert review.

### Constraints and Guardrails

**Security (HIPAA — non-negotiable):**
- Never log, display, or store PHI (patient names, emails, insurance IDs, phone numbers, payment info) in plaintext
- All patient-facing endpoints require Cognito auth with MFA (TOTP minimum)
- Row-level security: users see only their tenant's data
- S3 PHI storage requires encryption (KMS preferred). RDS SGs restricted to VPC CIDR
- Rate-limit all public API Gateway endpoints. WAF required on public endpoints
- Never expose internal tools (n8n, Metabase) to 0.0.0.0/0
- No 0.0.0.0/0 ingress on ANY security group
- All DB queries use parameterized statements
- Credentials go in AWS Secrets Manager via `secret-store` CLI. Never in chat, code, comments, or git URLs

**Infrastructure safety:**
- No security group modifications without explicit approval
- No DB migrations without a snapshot
- No DynamoDB Contacts table structure changes without approval (1.37M records)
- No direct pushes to main — branch + PR required
- No infrastructure deploy without `terraform plan` review first
- IaC via Terraform exclusively (no console-created resources)
- Manual CI/CD trigger only — never auto-deploy to prod
- RDS backup retention minimum 35 days
- Bland AI: versioned pathway endpoint only

**Working boundaries:**
- Propose a plan before touching more than 3 files
- State intent before destructive operations (DELETE, DROP, TRUNCATE, SG changes)

### Available Tools
- AWS MCP (102 read-only tools for infrastructure inspection)
- MyBCAT Ops MCP (1,126 docs, operational knowledge)
- MyBCAT Playbook MCP (security audits, procedures, onboarding)
- GitHub (CI/CD, repos, PRs)
- Terraform (infrastructure management)
- `secret-store` CLI (secrets management)

### Full Operational Playbook
For deeper context beyond these rules, query the **mybcat-playbook MCP** (`search_playbook`, `get_playbook_doc`, `list_playbook`)
<!-- MYBCAT-GUIDELINES-LEAN-END -->
```

- [ ] **Step 2: Deploy lean version to context_nate repo only**

```bash
# Backup current
cp /mnt/d_drive/repos/context_nate/CLAUDE.md /mnt/d_drive/repos/context_nate/CLAUDE.md.backup

# Copy lean version as the repo's CLAUDE.md (NOT the symlinked global one)
cp /mnt/d_drive/repos/.claude/CLAUDE-lean.md /mnt/d_drive/repos/context_nate/CLAUDE.md
```

- [ ] **Step 3: Run 5 test tasks on context_nate repo with lean CLAUDE.md**

Run these tasks in the context_nate repo and evaluate output quality:
1. "Read the business context file and summarize the top 3 security risks" — tests if model still identifies security issues without the architecture enumeration
2. "Write a Python script to parse the interception metrics JSONL file" — tests if model uses type hints, logging, f-strings without being told
3. "Create a new output file following the existing naming convention" — tests if model infers conventions from the repo
4. "What DynamoDB tables should we be careful with?" — tests if model knows about the 1.37M Contacts table without it being enumerated
5. "Draft a commit message for the changes we made today" — tests if model follows conventional commits without being told

**Evaluation criteria for each task:**
- Does the output follow MyBCAT code standards? (type hints, logging, parameterized queries)
- Does the output respect security constraints? (no PHI, no 0.0.0.0/0, secrets in Secrets Manager)
- Does the output quality match what the full CLAUDE.md would produce?

- [ ] **Step 4: Score results and decide**

| Task | Full CLAUDE.md Quality (baseline) | Lean CLAUDE.md Quality | Regression? |
|------|----------------------------------|----------------------|-------------|
| 1. Security summary | _/10 | _/10 | Y/N |
| 2. Python script | _/10 | _/10 | Y/N |
| 3. New output file | _/10 | _/10 | Y/N |
| 4. DynamoDB awareness | _/10 | _/10 | Y/N |
| 5. Commit message | _/10 | _/10 | Y/N |

**Decision criteria:**
- 0 regressions: Deploy lean version to all repos via symlink update
- 1-2 minor regressions: Add back the specific removed items that caused regression, deploy the rest
- 3+ regressions: Keep current CLAUDE.md, the scaffolding is still needed for this model generation

- [ ] **Step 5: If test passes — roll out**

```bash
# Replace the global CLAUDE.md with lean version
cp /mnt/d_drive/repos/.claude/CLAUDE-lean.md /mnt/d_drive/repos/.claude/CLAUDE.md

# The symlinks in all other repos will pick up the change automatically
# Verify one repo:
head -5 /mnt/d_drive/repos/agent-repair/CLAUDE.md
# Should show "MYBCAT-GUIDELINES-LEAN-START"
```

- [ ] **Step 6: If test fails — revert and document**

```bash
# Restore backup
cp /mnt/d_drive/repos/context_nate/CLAUDE.md.backup /mnt/d_drive/repos/context_nate/CLAUDE.md
```

Document which specific items caused regression in `06-token-usage-findings/03-claude-md-test-results.md`.

- [ ] **Step 7: Commit**

```bash
cd /mnt/d_drive/repos
git add .claude/CLAUDE-lean.md
git commit -m "feat: create lean CLAUDE.md for compensating complexity testing

39% smaller version with scaffolding removed, all security
constraints preserved. See 06-token-usage-findings for audit."
```

---

### Task 4: Sales Agent Node 02 (Research) — Outcome-Based A/B Test

**Purpose:** Test whether an outcome-based research prompt produces equal or better dossiers than the current 4-phase sequential procedure (55% scaffolding ratio).

**Files:**
- Create: `/mnt/d_drive/repos/sales_agent/nodes/02_research_outcome.md`
- Modify: `/mnt/d_drive/repos/sales_agent/controller.py` (add A/B toggle, if applicable)

- [ ] **Step 1: Create outcome-based Node 02**

Write `/mnt/d_drive/repos/sales_agent/nodes/02_research_outcome.md`:

```markdown
# Node 02: Research (Outcome-Based)

> A/B test version — compensating complexity audit 2026-04-02
> Original: 02_research.md (4-phase sequential, ~800 tokens)
> This version: outcome-based (~250 tokens)

## Role

You are a sales intelligence analyst for MyBCAT. Your job is to build a comprehensive research dossier on this lead — thorough enough to personalize outreach across LinkedIn, email, voice, and direct mail.

## Outcome

Produce a research dossier that answers:
1. **Who is the decision-maker?** (Name, title, authority level, confidence)
2. **Can this practice pay $10K+/month?** (Revenue signals, location count, growth indicators)
3. **What specific pain points can we reference?** (Verified findings only — Google reviews, job postings, website gaps, news)
4. **What's our engagement history?** (HubSpot contacts, email threads, prior outreach, meeting history)
5. **What hooks will work for personalized outreach?** (Specific, evidence-backed, not generic)

"I don't know" or "insufficient data" is always better than fabrication.

## Constraints

- **Pre-check gate:** Skip this lead entirely if ANY of these are true:
  - Duplicate already in pipeline (check HubSpot deal stage)
  - Active two-way conversation in last 14 days
  - Timing conflict (recent cancellation, active dispute, do-not-contact flag)
- Never fabricate findings. Mark confidence level (HIGH/MEDIUM/LOW) on each data point
- HubSpot is source of truth for engagement history
- Do not contact the lead during research — observation only
- If a data source is unavailable, note it and proceed with what you have

## Available Tools

- **HubSpot CRM:** Contact records, deal history, engagement timeline, company associations
- **Gmail:** Prior email threads with this contact or domain
- **LinkedIn:** Profile data, company page, mutual connections, recent activity
- **Web Search:** Google reviews, practice website, local news, job postings, industry publications
- **MyBCAT Ops MCP:** Prior client interactions, meeting notes, chat history

## Output Format

```json
{
  "lead_id": "string",
  "research_timestamp": "ISO-8601",
  "pre_check_result": "PROCEED | SKIP_DUPLICATE | SKIP_ACTIVE_CONVERSATION | SKIP_TIMING",
  "decision_maker": {
    "name": "string",
    "title": "string",
    "authority_confidence": "HIGH | MEDIUM | LOW",
    "source": "string"
  },
  "financial_signals": {
    "estimated_locations": "number",
    "revenue_signals": ["string"],
    "can_pay_10k_confidence": "HIGH | MEDIUM | LOW"
  },
  "pain_signals": [
    {"signal": "string", "source": "string", "confidence": "HIGH | MEDIUM | LOW"}
  ],
  "engagement_history": {
    "hubspot_contacts": "number",
    "email_threads": "number",
    "prior_outreach": ["string"],
    "relationship_status": "COLD | WARM | HOT | EXISTING"
  },
  "recommended_hooks": [
    {"hook": "string", "evidence": "string", "best_channel": "string"}
  ],
  "data_gaps": ["string"],
  "research_sources_used": ["string"]
}
```
```

- [ ] **Step 2: Select 10 test leads**

Run in HubSpot: Pull 10 leads from the qualification pipeline that haven't been researched yet. Mix of:
- 3 cold leads (no prior engagement)
- 3 warm leads (some HubSpot history)
- 2 multi-location practices
- 2 single-location practices

Record lead IDs for the A/B test.

- [ ] **Step 3: Run each lead through BOTH versions**

For each of the 10 leads:
1. Run through original `02_research.md` → save dossier as `dossier_original_{lead_id}.json`
2. Run through `02_research_outcome.md` → save dossier as `dossier_outcome_{lead_id}.json`

- [ ] **Step 4: Score dossier quality**

For each lead, score both dossiers on:

| Criterion | Weight | Original Score (1-10) | Outcome Score (1-10) |
|-----------|--------|----------------------|---------------------|
| Decision-maker identified | 25% | | |
| Financial signals present | 20% | | |
| Pain signals specific + evidence-backed | 25% | | |
| Engagement history complete | 15% | | |
| Hooks actionable + personalized | 15% | | |

- [ ] **Step 5: Decision gate**

Calculate weighted average for each version across all 10 leads.

**Decision criteria:**
- Outcome version scores within 10% of original: **Deploy outcome version** (simpler, more adaptable)
- Outcome version scores 10%+ higher: **Deploy outcome version** (strictly better)
- Outcome version scores 10%+ lower: **Keep original**, add back the specific procedural items that mattered
- Mixed results by lead type: Consider using outcome version for warm leads (more data available) and original for cold leads (needs more structure)

- [ ] **Step 6: Implement winner**

If outcome version wins:
```bash
cd /mnt/d_drive/repos/sales_agent
cp nodes/02_research.md nodes/02_research_sequential_backup.md
cp nodes/02_research_outcome.md nodes/02_research.md
git add nodes/
git commit -m "feat: replace sequential research node with outcome-based version

A/B test showed outcome version produces equal/better dossiers
with 69% fewer tokens. Model decides research order dynamically."
```

---

### Task 5: Sales Agent Node 03 (Qualification) — Outcome-Based A/B Test

**Purpose:** Test whether removing the point-scoring matrix allows the model to make better qualify/disqualify decisions from first principles.

**Files:**
- Create: `/mnt/d_drive/repos/sales_agent/nodes/03_qualification_outcome.md`

- [ ] **Step 1: Create outcome-based Node 03**

Write `/mnt/d_drive/repos/sales_agent/nodes/03_qualification_outcome.md`:

```markdown
# Node 03: Qualification (Outcome-Based)

> A/B test version — compensating complexity audit 2026-04-02
> Original: 03_qualification.md (point-scoring matrix, ~700 tokens)
> This version: outcome-based (~200 tokens)

## Role

You are a lead qualification analyst for MyBCAT. Your job is to make a binary decision: should we invest outreach effort on this lead, or not?

## Outcome

Evaluate the research dossier and produce a qualification decision with supporting evidence. Be conservative with disqualifications — a lost opportunity is worse than a wasted touch.

## Three Core Criteria

1. **Decision-maker identified:** Is there a named person with authority to approve a $10K+/month service contract? Practice owners, managing partners, and PE group operations leads qualify. Office managers typically don't.

2. **Can pay $10K+/month:** Does the practice have the revenue to support MyBCAT's pricing? Signals: multiple locations, established practice (5+ years), growth indicators (hiring, expanding, acquiring), PE backing. Red flags: single location struggling with reviews, recent downsizing.

3. **Healthcare vertical:** Is this an optometry practice (primary target) or adjacent healthcare that could benefit from call center services? Non-healthcare is a hard disqualify.

## Constraints

- Never disqualify solely on thin data. If you can't find enough information, the decision is HOLD, not DISQUALIFY
- Always cite specific evidence for your decision (quote the research dossier)
- A lead that meets 2 of 3 criteria with strong signals should PROCEED
- A lead that meets all 3 weakly should PROCEED_SOFT (deposit touch, no hard ask)

## Output Format

```json
{
  "lead_id": "string",
  "decision": "PROCEED | PROCEED_SOFT | HOLD_FOR_RESEARCH | DISQUALIFY",
  "confidence": "HIGH | MEDIUM | LOW",
  "evidence": {
    "decision_maker": {"met": true/false, "evidence": "string"},
    "can_pay": {"met": true/false, "evidence": "string"},
    "healthcare": {"met": true/false, "evidence": "string"}
  },
  "reasoning": "string (2-3 sentences)",
  "next_action": "string"
}
```
```

- [ ] **Step 2: Use the same 10 leads from Task 4**

Run each lead's research dossier through both qualification versions.

- [ ] **Step 3: Score qualification accuracy**

For each lead, compare decisions:

| Lead | Original Decision | Outcome Decision | Match? | Which is more accurate? (manual review) |
|------|------------------|-----------------|--------|----------------------------------------|
| 1 | | | | |
| ... | | | | |
| 10 | | | | |

- [ ] **Step 4: Decision gate**

**Decision criteria:**
- 8+ of 10 decisions match, and manual review agrees with outcome version: **Deploy outcome version**
- 6-7 match, outcome version makes better calls on disagreements: **Deploy outcome version**
- <6 match, or outcome version makes worse calls: **Keep original scoring matrix**

- [ ] **Step 5: Implement winner**

Same pattern as Task 4 — backup original, deploy winner, commit with test results.

---

### Task 6: Skills Library Audit (87+ Skills)

**Purpose:** Categorize all 87+ Claude Code skills as outcome-based, procedural, or platform-specific. Identify candidates for simplification or archival.

**Files:**
- Create: `/mnt/d_drive/repos/context_nate/outputs/06-token-usage-findings/skills-audit.md`

- [ ] **Step 1: List all skills with metadata**

```bash
# Get all skill directories with their SKILL.md files
find ~/.claude/skills -name "SKILL.md" -o -name "*.md" | head -100
# Count total
find ~/.claude/skills -maxdepth 2 -name "SKILL.md" | wc -l
```

- [ ] **Step 2: For each skill, read the first 20 lines and categorize**

Create a script to batch-read skill files and extract key metadata:

```bash
for skill_dir in ~/.claude/skills/*/; do
  skill_name=$(basename "$skill_dir")
  skill_file=""
  if [ -f "$skill_dir/SKILL.md" ]; then
    skill_file="$skill_dir/SKILL.md"
  elif [ -f "$skill_dir/skill.md" ]; then
    skill_file="$skill_dir/skill.md"
  fi
  if [ -n "$skill_file" ]; then
    echo "=== $skill_name ==="
    head -20 "$skill_file"
    echo ""
  fi
done > /tmp/skills-scan.txt
```

- [ ] **Step 3: Categorize each skill**

Read `/tmp/skills-scan.txt` and categorize each skill into the audit table:

| Category | Definition | Example |
|----------|-----------|---------|
| **Outcome-based** | Defines what to achieve + constraints. Minimal procedural content. Survives model upgrades | "Send email via Gmail API" |
| **Procedural** | Step-by-step instructions telling the model how to do something. May be unnecessary with better model | "First check X, then do Y, then verify Z" |
| **Platform-specific** | Interfaces with specific APIs/tools. Needed regardless of model capability | "Authenticate with HubSpot OAuth, call specific endpoints" |
| **Hybrid** | Mix of outcome and procedural. Could be simplified | Most skills |

- [ ] **Step 4: Write the audit document**

Save to `/mnt/d_drive/repos/context_nate/outputs/06-token-usage-findings/skills-audit.md`:

```markdown
# Skills Library Audit — 87+ Claude Code Skills

**Date:** 2026-04-02
**Method:** Read first 20 lines of each skill, categorize by compensating complexity type

## Summary
- Total skills: X
- Outcome-based: X (keep as-is)
- Procedural: X (candidates for rewrite)
- Platform-specific: X (keep as-is)
- Hybrid: X (candidates for simplification)
- Estimated scaffolding ratio: X%

## Top 10 Simplification Candidates
[Skills with highest procedural content that would benefit most from outcome-based rewrite]

## Full Audit Table
| # | Skill | Category | Last Modified | Recommendation |
|---|-------|----------|--------------|----------------|
| 1 | ... | ... | ... | Keep / Rewrite / Archive |
```

- [ ] **Step 5: Commit the audit**

```bash
cd /mnt/d_drive/repos/context_nate
git add outputs/06-token-usage-findings/skills-audit.md
git commit -m "docs: complete skills library audit for compensating complexity

87+ skills categorized as outcome/procedural/platform-specific.
Top 10 simplification candidates identified."
```

- [ ] **Step 6: Decision gate — prioritize rewrites**

Pick the top 3 procedural skills by usage frequency. Rewrite each using the outcome-based pattern from Task 4. Test each rewrite against 3 real tasks before deploying.

---

## Execution Order (Recommended)

```
PARALLEL TRACK A (instrumentation):   Task 1 + Task 2 (day 1-2)
PARALLEL TRACK B (CLAUDE.md test):    Task 3 (day 1-5, needs 3-day observation)
PARALLEL TRACK C (skills audit):      Task 6 (day 1-3)

SEQUENTIAL (after instrumentation):   Task 4 (day 8-14, needs production data from Tasks 1-2)
SEQUENTIAL (after Task 4):            Task 5 (day 14-21, uses same test leads)

DECISION GATES:
  Day 7:  Review Task 1 + 2 interception data → decide verification changes
  Day 5:  Review Task 3 test results → decide CLAUDE.md rollout
  Day 14: Review Task 4 A/B results → decide Node 02 deployment
  Day 21: Review Task 5 A/B results → decide Node 03 deployment
  Day 3:  Review Task 6 audit → prioritize skill rewrites
```

**Total estimated effort:** ~25-30 hours over 3 weeks
**Risk level:** Low — all changes are tested before deployment, all have revert paths
