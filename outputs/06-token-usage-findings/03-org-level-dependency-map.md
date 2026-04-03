# Prompt 3: Org-Level Model Dependency Map — MyBCAT

**Date:** 2026-04-02
**Framework:** Nate's Newsletter — "A Better Model Can Make Your AI Product Worse" Prompt Kit
**Diagnostic Question:** "If the model's error rate dropped by 80%, would this role or process still exist in its current form?"

---

## Team Overview

- **US Leadership (4):** Ankit Patel (CEO), Bre Dameron (VP Ops/COO), Justin Beecher (Finance), Phoebes Ilagan (Bookkeeping)
- **PH Operations (6):** Kristine "Kay" Sta. Monica (Ops Mgr), Kei (QA/Performance), Nofa Lee (HR), Rea (L&D), Chad (Sr Lead Supervisor), Angela Frades (Supervisor)
- **Tech (3):** Vince Casimiro (Tech Lead), Mohamed Reda (Dev), Juan Rodriguez (Dev)
- **Agents (60+):** Filipino call center agents — calls, scheduling, insurance verification, back-office tasks
- **AI Systems in Production:** 87+ Claude Code skills, 6-7 concurrent agents, repair bot, 12-node sales agent pipeline, Bland AI voice bot, 106 Lambda functions, Bedrock call analysis, Deepgram transcription

---

## Model Dependency Map

| Role/Process | Category | Model Limitation Compensated | Impact if Model Improves 80% | Klarna Risk |
|---|---|---|---|---|
| **Ankit (CEO)** | Model-Independent | N/A — strategy, sales, relationships, vision | Role unchanged. May shift time from prompt engineering to strategy | Low |
| **Bre (VP Ops/COO)** | Hybrid | Manages human agents + compensates for AI not handling complex client escalations | Client relationship work stays; operational oversight of agent quality could shift from human QA to AI QA | Medium |
| **Justin (Finance)** | Model-Independent | N/A — financial judgment, vendor relationships, cash flow decisions | Unchanged | Low |
| **Phoebes (Bookkeeping)** | Hybrid | Data entry and reconciliation that AI could handle; judgment calls on categorization stay | Routine reconciliation may automate; exception handling stays | Low |
| **Kay (PH Ops Mgr)** | Model-Independent | N/A — people management, culture, team coordination | Unchanged | Low |
| **Kei (QA/Performance)** | **Model-Dependent (Scaling)** | Reviews agent call quality because AI analysis isn't reliable enough for all call types | If AI call analysis improves 80%, QA review volume drops dramatically. Role shifts from reviewer to exception handler | **High** |
| **Nofa Lee (HR)** | Model-Independent | N/A — compliance, hiring, labor relations, agent welfare | Unchanged | Low |
| **Rea (L&D)** | Hybrid | Training content creation scales with model limits; training design and delivery stays human | Content creation shifts to AI-generated; instructional design judgment stays | Medium |
| **Chad, Angela (Supervisors)** | Hybrid | Real-time agent support + escalation handling for cases AI can't resolve | Supervision stays; escalation volume drops as AI handles more autonomously | Medium |
| **60+ Call Center Agents** | **Model-Dependent (Scaling)** | Handle inbound calls, scheduling, insurance verification, recalls — core tasks that voice AI (Bland AI) is already attempting | **Highest Klarna-risk area.** If voice AI handles 80% of call types reliably, the math on 60+ agents changes fundamentally. Currently voice AI is after-hours/overflow only — a step change could expand scope | **HIGH** |
| **Vince (Tech Lead)** | Hybrid | Maintains infrastructure + reviews AI-generated code (Claude Code writes 90%) | Code review burden drops; architecture decisions, security review, and production ownership stay | Medium |
| **Mohamed, Juan (Devs)** | **Model-Dependent (Scaling)** | Write code that Claude Code already writes ~90% of; maintain prompts and pipelines | If model needs less scaffolding (42% of current prompts), prompt maintenance drops. Architecture and deployment ownership stays | **High** |
| **Repair Bot (automated)** | Model-Dependent | Exists because infrastructure breaks and AI agents cause issues needing automated remediation | Better models = fewer issues = less repair work. But production will always need monitoring | Medium |
| **Sales Agent Pipeline (12 nodes)** | Model-Dependent | 12-node procedural pipeline exists because model can't handle end-to-end sales research + outreach autonomously | With a step-change model, the 12 nodes could collapse to 3-4 outcome-based agents. Pipeline maintenance burden drops significantly | High |
| **87+ Claude Code Skills** | **Model-Dependent (Scaling)** | Each skill encodes procedural knowledge for a specific task type | A model that reasons well from context and tools needs fewer rigid skill definitions. Many skills may be collapsible | **High** |
| **QA Runner (qa_runner.py)** | Model-Dependent | Verifies AI-generated outreach messages before sending to leads | If model error rate drops 80%, QA pass rates increase from current level and the runner catches fewer real errors | Medium |
| **Bland AI Voice Bot** | Model-Dependent | After-hours/overflow voice handling with scripted pathways | Better voice models could handle more call types, expanding from overflow to primary answering for certain call categories | High |

---

## Key Findings

### Model Dependency Distribution
- **Model-Independent:** 6 roles/processes (35%)
- **Hybrid:** 5 roles/processes (29%)
- **Model-Dependent (Scaling):** 6 roles/processes (35%)
- **Overall: 52% of described roles/processes have model-dependent components**

### Highest Klarna-Risk Areas

**1. 60+ Call Center Agents (HIGHEST RISK)**
- MyBCAT's entire business model rests on human agents being better than AI at phone calls
- Bland AI already handles after-hours/overflow — a step change in voice AI could expand its scope significantly
- Revenue ($1.3M) directly tied to selling human agent services
- A Klarna-style scenario: if voice AI gets good enough, clients may question why they're paying $600/week for human agents
- **Mitigation:** Start measuring AI vs. human resolution rates per call type NOW. Identify call categories where AI already performs well vs. where humans are essential. Build the data before the market forces the question

**2. 87+ Skills Library (HIGH RISK)**
- Massive investment in procedural scaffolding
- Each skill was likely built for a specific model generation's limitations
- A step-change model may not need 80% of the procedural content in these skills
- **Mitigation:** Audit each skill using the Prompt 1 framework. Tag as outcome vs. procedure. Archive procedural skills as the model proves it doesn't need them

### Rock-Solid Model-Independent Foundation
These roles survive ANY model upgrade:
- **Ankit:** Strategy, sales, client relationships, vision
- **Bre:** Client relationship management, operational judgment
- **Kay:** People management, culture, team coordination (PH team)
- **Justin:** Financial judgment, vendor management
- **Nofa Lee:** HR, compliance, labor relations
- **HIPAA constraints layer:** Regulatory requirements don't change with model capability

---

## Readiness Actions

### Measure Now (This Week)
1. **Bland AI vs. human resolution rates by call type** — Start tracking which call categories the voice bot resolves successfully vs. which require human follow-up
2. **QA runner interception rates** — How often does qa_runner.py actually change output vs. rubber-stamp it?
3. **Skills usage frequency** — Which of the 87+ skills are actually invoked regularly vs. dormant?

### Prepare (Next 2 Weeks)
4. **Tag each of the 87 skills** as outcome-based vs. procedural scaffolding
5. **Map agent tasks by AI-replaceability** — Not all call types are equal. Insurance verification may be more automatable than complex scheduling
6. **Document the "human-only" call categories** where agent judgment is irreplaceable (angry patients, complex insurance disputes, multi-party scheduling)

### Do NOT Do Yet
7. **Do NOT make staffing decisions** based on this map. It's a preparation tool, not an action plan
8. **Do NOT reduce agent headcount** before measuring actual AI performance on each call type
9. **Do NOT eliminate QA processes** before measuring interception rates

---

## What Stays (Any Model Upgrade)

| What | Why |
|------|-----|
| Client relationships (Bre, Ankit) | Trust is human. Clients buy from people |
| People management (Kay, supervisors) | 60+ remote workers need human leadership regardless of AI capability |
| Financial judgment (Justin, Phoebes) | Cash flow decisions, vendor negotiations, exception handling |
| HR/Compliance (Nofa Lee) | Labor law, agent welfare, regulatory compliance |
| Architecture ownership (Vince) | Someone must own production systems, security, and deployment |
| HIPAA constraints | Regulatory — model-independent by definition |
| Training design (Rea) | Even AI-trained agents need human instructional design |
| Escalation path to humans | Patients will always need human-to-human option for sensitive matters |

---

## The Strategic Question

Nate's article frames this as: "Which parts of your org are application logic (genuinely needed regardless of model capability) and which parts are compensating for the model's limitations?"

For MyBCAT, the strategic version is: **"If voice AI gets 80% better, is MyBCAT a company that sells human agents, or a company that sells managed call center outcomes?"**

The answer to that question determines whether the 60+ agent workforce is application logic or compensating complexity. If MyBCAT sells *outcomes* (patients scheduled, insurance verified, recalls completed), then the delivery mechanism (human vs. AI) is an implementation detail that should follow the best available technology. If MyBCAT sells *human agents specifically*, then a voice AI step change is an existential threat.

This is the Klarna lesson applied to MyBCAT's core business model. The time to decide is before the step change, not after.
