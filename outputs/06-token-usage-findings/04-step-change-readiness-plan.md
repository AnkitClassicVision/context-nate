# Prompt 4: Step-Change Readiness Plan — MyBCAT

**Date:** 2026-04-02
**Framework:** Nate's Newsletter — "A Better Model Can Make Your AI Product Worse" Prompt Kit
**Five Monday Principles:**
1. Treat every model upgrade as a deletion opportunity
2. Separate your "what" from your "how" in writing, today
3. Log your interception rates now
4. Identify your org chart's model dependency
5. Build your next system around outcomes and tools, not procedures

---

## Situation Assessment

MyBCAT runs 25+ production AI prompts across 5 systems with a **42% compensating complexity ratio**. The highest-risk areas are the 12-node sales agent pipeline (40% scaffolding), the 87-skill Claude Code library (unmeasured), and the 60+ agent workforce whose jobs are the direct target of voice AI improvements. You have a 3-person tech team (Vince, Mohamed, Juan) and the founder (Ankit) as primary prompt engineer. Bandwidth is limited. A new model tier (Claude Mythos) is imminent.

---

## Priority Ranking of the Five Principles

| Rank | Principle | Justification |
|------|-----------|---------------|
| **1** | Separate "what" from "how" | You have 200+ prompt components and don't currently know which are outcomes vs. procedures. This is the prerequisite for everything else |
| **2** | Treat upgrades as deletion opportunities | With 42% compensating complexity, there's significant room to simplify when the next model drops |
| **3** | Log interception rates | Your QA runner and repair bot are verification layers with unknown interception rates. You need data |
| **4** | Build around outcomes, not procedures | The sales agent pipeline is the biggest rewrite target (12 nodes → 3-4 outcome agents) |
| **5** | Map org model dependency | Done (Prompt 3). Now maintain it |

---

## Phase 1: This Week (6-8 hours total)

### Action 1: Deploy Lean CLAUDE.md to One Test Repo
**What:** Take the rewritten CLAUDE.md from the Prompt 2 output (39% smaller, all constraints preserved). Deploy it to one low-risk repo (e.g., context_nate or a documentation repo). Run normal tasks for 3 days and compare output quality.

**Why now:** CLAUDE.md is your most-deployed prompt (every repo via symlink). Validating the lean version on one repo is low-risk and tells you immediately whether the removed scaffolding was necessary.

**Time:** 1 hour (copy rewrite, update symlink for one repo, run 3-5 test tasks)

**Done when:** One repo running on the lean CLAUDE.md for 3 days with no quality regression in code output.

**Connects to:** Principle 2 (what vs. how separation). If validated, roll out to all repos in Phase 2.

---

### Action 2: Add Interception Logging to qa_runner.py
**What:** Add a simple counter to qa_runner.py that tracks two metrics:
- `qa_passed_without_changes` — QA approved the output as-is
- `qa_caught_real_error` — QA flagged and modified the output

Emit both to CloudWatch or a simple log file.

**Why now:** You can't measure what you don't log. Without interception rates, you don't know if your QA layer is catching 30% of errors or 2%. This data is essential for Phase 2 decisions.

**Time:** 2 hours

**Done when:** qa_runner.py emits pass/fail/change metrics on every run, visible in CloudWatch or logs.

**Connects to:** Principle 3 (log interception rates). Provides data for Phase 2 verification thinning.

---

### Action 3: Add Interception Logging to repair_bot.py
**What:** Same principle as Action 2. Track:
- `action_taken` — repair bot actually fixed something
- `no_action_needed` — repair bot confirmed system was healthy
- `action_type` — what kind of fix (restart, config change, code patch)

**Why now:** If repair bot confirms healthy 95% of the time, your monitoring is working but the bot is mostly a confirmation step. That's useful data.

**Time:** 1 hour

**Done when:** repair_bot.py logs action/no-action on every run.

**Connects to:** Principle 3. Provides data for repair bot simplification in Phase 2.

---

### Action 4: Tag CLAUDE.md Components
**What:** Using the Prompt 1 audit table, add inline comments to the current CLAUDE.md marking each block as OUTCOME, CONSTRAINT, SCAFFOLDING, or COMPENSATION. This makes the categorization visible to anyone editing the file.

**Why now:** When the next model drops, you need to know which lines to test for deletion. Tags make this instant instead of re-doing the audit under time pressure.

**Time:** 30 minutes

**Done when:** Every section of CLAUDE.md has a category tag comment.

**Connects to:** Principle 2 (what vs. how separation). Enables rapid deletion testing in Phase 3.

---

### Action 5: Swap Model on Repair Bot for 48-Hour Test
**What:** Update repair_bot.py to use the newest available model. Run for 48 hours with interception logging active (Action 3).

**Why now:** Repair bot is the safest candidate for model upgrade testing — it's sandboxed (limited to 5 file paths), auditable (logs every action), and has a human-review gate (email notifications). Low blast radius.

**Time:** 30 minutes to swap model string + 48 hours of observation

**Done when:** 48 hours of repair bot runs on new model with no regressions, interception data collected.

**Connects to:** Principle 1 (deletion opportunity). If new model performs better, you can test removing scaffolding items from repair bot prompt.

---

## Phase 2: Next Two Weeks

### Action 6: A/B Test Outcome-Based Sales Agent Node 02
**What:** Deploy the rewritten Node 02 (Research) from Prompt 2 alongside the current version. Run 10 leads through each. Compare dossier completeness (are all sections filled?) and quality (are pain signals specific and evidence-backed?).

**Why now:** Node 02 has the highest scaffolding ratio (55%) and feeds all downstream outreach. If the outcome-based version produces equal or better dossiers, it validates the simplification pattern for the entire pipeline.

**Time:** 4 hours setup + 1 week of parallel runs

**Done when:** 10 leads processed through both versions, comparison documented, winner identified.

**Connects to:** Principles 1 + 4. Validates outcome-based architecture for the sales pipeline.

---

### Action 7: A/B Test Outcome-Based Sales Agent Node 03
**What:** Same as Action 6 but for the Qualification node. Remove the point-scoring matrix, give model the 3 criteria + 10 example leads with known good/bad outcomes. Test if it makes better qualify/disqualify decisions from first principles.

**Why now:** Node 03 gates everything downstream. If point-scoring is constraining better judgment, you're losing leads or wasting outreach on bad ones.

**Time:** 3 hours setup + 1 week of parallel runs

**Done when:** 10 leads qualified through both versions, decision quality compared.

**Connects to:** Principles 1 + 4.

---

### Action 8: Audit 87 Skills — Tag Each as Outcome vs. Procedure
**What:** Go through each of the 87+ Claude Code skills. For each, categorize as:
- **Outcome-based:** Defines what to achieve + constraints. Survives model upgrades
- **Procedural:** Step-by-step instructions. May be unnecessary with better model
- **Platform-specific:** Interfaces with specific APIs/tools. Needed regardless of model

Create a spreadsheet with: skill name, category, last used date, recommendation (keep/test/archive).

**Why now:** This is the largest unmeasured compensating complexity surface in MyBCAT. 87 skills at an estimated 40% scaffolding ratio = ~35 skills worth of procedural content that may be constraining model performance.

**Time:** 4-6 hours (batch through skills, ~3-4 minutes each)

**Done when:** Spreadsheet complete for all 87+ skills with category and recommendation.

**Connects to:** Principle 2 (what vs. how separation). Enables skills consolidation in Phase 3.

---

### Action 9: Review Phase 1 Interception Data
**What:** After 2 weeks of qa_runner.py and repair_bot.py interception logging, pull the data and write a one-page summary:
- QA runner: X% of runs catch real errors, Y% rubber-stamp
- Repair bot: X% of runs take action, Y% confirm healthy

**Why now:** This data tells you whether your verification layers are catching real problems or mostly confirming correct output. If QA catches <5% of runs, that's a strong signal the model is already good enough for most cases.

**Time:** 1 hour

**Done when:** Written summary with percentages and recommendation (thin/keep/shift verification).

**Connects to:** Principle 3. Drives verification decisions in Phase 3.

---

### Action 10: Start Measuring Bland AI vs. Human Resolution Rates
**What:** Set up tracking for call outcomes by handler type (Bland AI vs. human agent) and call category (scheduling, insurance verification, recall, general inquiry). Track: call resolved (yes/no), patient satisfaction (if measurable), follow-up required (yes/no).

**Why now:** Prompt 3 identified the 60+ agent workforce as the highest Klarna risk. You need baseline data on where AI already performs well vs. where humans are essential, before the market forces the question.

**Time:** 2-4 hours to set up tracking in Connect analytics

**Done when:** Dashboard showing AI vs. human resolution rate per call category, updating daily.

**Connects to:** Principle 4 (org model dependency). Provides data for strategic workforce decisions.

---

## Phase 3: Before Next Model Upgrade

### Action 11: Roll Out Lean CLAUDE.md to All Repos
**Depends on:** Phase 1 Action 1 validation (3 days on one repo)

**What:** If the lean CLAUDE.md shows no regression, update the symlink source so all repos get the 39%-smaller version.

**Time:** 1 hour

---

### Action 12: Collapse Sales Agent Pipeline
**Depends on:** Phase 2 Actions 6-7 validation

**What:** If outcome-based Nodes 02 and 03 perform equal or better, apply the same rewrite to remaining nodes. Target: collapse 12 procedural nodes into 3-4 outcome-based agents:
1. **Research + Qualify Agent** (replaces Nodes 01-03)
2. **Outreach Agent** (replaces Nodes 04-09, decides channels dynamically)
3. **Follow-Up + Booking Agent** (replaces Nodes 10-11)
4. **Record Agent** (replaces Node 12)

**Time:** Full sprint (1-2 weeks)

---

### Action 13: Consolidate Skills Library
**Depends on:** Phase 2 Action 8 audit

**What:** Archive procedural skills the model no longer needs. Merge overlapping outcome-based skills. Target: reduce from 87+ to ~40-50 lean, outcome-based skills.

**Time:** Ongoing over 2-3 weeks

---

### Action 14: Establish Model-Upgrade Runbook
**What:** Document the process for handling any future model upgrade:
1. Swap model string on repair bot (lowest risk) — 48-hour test
2. Run deletion tests on all "TEST" items from Prompt 1 audit
3. Measure interception rates before and after
4. Rewrite highest-scaffolding prompts using outcome-based architecture
5. Roll out in order: repair bot → CLAUDE.md → sales pipeline → skills

**Time:** 2 hours to document

**Done when:** Written runbook in playbook that any team member can follow.

---

## Quick Wins (Under 30 Minutes Each)

### 1. Diff the CLAUDE.md rewrite (5 minutes)
Take the rewritten CLAUDE.md from `02-outcome-based-rewriter.md` and diff it against the current `/mnt/d_drive/repos/.claude/CLAUDE.md`. You'll immediately see the 39% that's scaffolding vs. the 61% that's real constraints.

### 2. Count procedural verbs in Sales Node 06 (10 minutes)
Open the voice outreach node and highlight every "first," "then," "next," and timing constraint ("5-8s," "10-15s"). Each one is a bet against the model getting smarter at voice interactions. There are at least 8.

### 3. Check repair bot logs (15 minutes)
Pull the last 30 days of repair bot runs. Count: how many actually fixed something vs. confirmed healthy? If >80% are confirmations, your infrastructure is more stable than you think, and the bot's verification budget is mostly confirming things that were already correct.

---

## What to Watch For

### Signs You Have More Duct Tape Than Expected
- QA runner pass-without-changes rate > 90%
- Skills that nobody has updated in 3+ months (calcified scaffolding)
- System prompts > 500 tokens that haven't been A/B tested against shorter versions
- Team members who spend >50% of time on prompt maintenance

### Signs You're in Better Shape Than Expected
- CLAUDE.md is already mostly constraints (it is — 61%)
- Repair bot is already sandboxed and auditable
- You have measurement infrastructure (MCPs, CloudWatch, Monday.com, Connect analytics)
- Sales agent has a QA gate that can be measured immediately
- Scar tissue rules are high-quality constraints that survive any upgrade

---

## Timeline Summary

```
Week 1:  Tag CLAUDE.md | Log interception rates | Test lean CLAUDE.md | Swap repair bot model
Week 2:  A/B test Node 02 | Start skills audit | Set up AI vs. human tracking
Week 3:  A/B test Node 03 | Complete skills audit | Review interception data
Week 4:  Roll out lean CLAUDE.md (if validated) | Begin pipeline collapse design
Week 5+: Execute pipeline collapse | Consolidate skills | Write runbook
```

**Total estimated effort:** ~30-40 hours over 5 weeks, primarily Ankit + Vince time.
