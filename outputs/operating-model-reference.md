> Load for planning, strategy, prioritization, or burnout topics.
> Skip for routine coding, tests, builds, narrow fixes, and status checks.
> Installed location: `/mnt/d_drive/repos/context_nate/outputs/operating-model-reference.md`.

# Operating Model Reference

Curated from `/mnt/d_drive/repos/OB_mybcat/exports/operating-model/USER.md`, `/mnt/d_drive/repos/OB_mybcat/exports/operating-model/SOUL.md`, and `/mnt/d_drive/repos/OB_mybcat/exports/operating-model/HEARTBEAT.md`. Duplicate generated text has been removed.

## USER

### Operating Rhythms

Days are not time-blocked into build vs. non-build. Ankit runs concurrent Claude Code and Codex sessions as an always-on background process, remote-controlled while meetings, sales calls, interviews, and hiring work happen on top. Early morning is the real deep-work window, conditional on stress being managed. The day is anchored by two personal rituals, brave cortado at start and hot shower at end, plus the trainer 3x/week, not by the calendar. The lighthouse block on the calendar is calendar theater and rarely executes. Burnout is concentrated in three compounding forces: parallel-thread count, context-switch tax, and back-to-back meeting days with no open block. Current active threads: sales (HubSpot Daily 2), hiring (GM and developer), Bill.com integration, OpenBrain and AI tooling, upcoming website-health work.

- Concurrent AI-orchestrated workday: Work happens as continuous background AI execution (Claude Code and Codex sessions running all day, accessed via remote control) interleaved with live meetings, sales calls, interviews, and hiring work. No dedicated build blocks; building and people-time overlap throughout the day.
  Cadence: daily
  Trigger: session start after morning hygiene and brave cortado
  Stakeholders: Ankit, sales prospects, hiring candidates, AI agents
  Constraints: no fixed focus window, agents must run unattended while Ankit is in meetings, cross-thread context switching is constant
- Morning sharpness window: Cognitive sharpness is front-loaded. Hard problems (architecture, debugging, writing) land best early in the day, conditional on stress being in check. Later in the day degrades into reactive and admin capacity.
  Cadence: daily
  Trigger: post-hygiene, post-cortado; pre-meeting-density
  Stakeholders: Ankit
  Constraints: degrades fast if stress spikes, degrades fast if back-to-back meetings hit early
- Ritual anchors: cortado, shower, trainer. The day is bookended by two personal rituals (brave cortado in the morning at home, hot shower at night) plus the trainer 3x/week. These are the only reliable day-shape anchors; the calendar itself is not.
  Cadence: daily (cortado, shower); 3x/week (trainer)
  Trigger: wake (cortado); end of work (shower); scheduled training session (trainer)
  Stakeholders: Ankit, trainer
  Constraints: trainer slot time-of-day not locked in interview
- Back-to-back meetings as burnout trigger: Three compounding forces drive burnout: (a) sheer parallel-thread count (sales, hiring, multiple app builds, upcoming website work), (b) continuous context-switch tax, and (c) back-to-back meeting days with no block for work or downtime. Talking-to-people days specifically drain fast.
  Cadence: variable, triggered whenever a day lands meeting-heavy
  Trigger: calendar day with back-to-back meetings and no open block
  Stakeholders: Ankit, anyone who schedules onto Ankit's calendar
  Constraints: no current automated defense against back-to-back load, no enforced no-meeting windows

### Recurring Decisions

Four recurring judgment calls dominate right now. (1) Outbound sales contact: picking channel (email, LinkedIn, or postcard) and personalizing the message per prospect, partially encoded in HubSpot Daily 2; cold outreach uses postcard or LinkedIn, never email or text, to avoid spam risk; warm outreach uses email or text. (2) Call quality assessment: a mix of measurable KPIs (near-automated) and subjective cues (tone, warmth, laughter, reading between lines) that still need a human; currently no retroactive review process even though Fathom recordings exist. (3) People-quality assessment for hiring and management: the articulated framework is four-lens (routing tasks, sense-making, capacity-building, accountability), but the operational read is binary: A-player (proactive, predictive, delivers ahead of ask, solves without being told, self-orients to company direction) vs. have-to-baby-them. (4) Daily thread prioritization: currently vibes-driven with sales as the only structural anchor because Ankit owns sales personally. Ankit has explicitly flagged this as his biggest operational weakness and is asking for help building an annual to quarterly to weekly to daily objective cascade to stay focused on what matters vs. what feels urgent.

- Outbound channel and message selection: For each sales prospect, pick channel (email, LinkedIn, or postcard) and message personalization based on prospect context. The goal is warmth, connection, and value-add, not volume.
  Cadence: daily (automated via HubSpot Daily 2 repo, with periodic human overrides)
  Trigger: new lead enters pipeline, or a warm lead needs follow-up
  Stakeholders: Ankit, HubSpot Daily 2 repo, prospect, HubSpot CRM
  Constraints: spam risk on cold email or text, persona mismatch risk, automation drift from Ankit's actual writing voice
- Call quality assessment: Decide whether a patient phone call was actually good. Measurable KPIs are close to automation, but the subjective layer (tone, warmth, frictionlessness, patient laughter, reading between lines) still requires human listening. Currently no retroactive review process; Fathom recordings exist but Ankit does not revisit them.
  Cadence: per-call in principle; in practice rarely revisited
  Trigger: completed call, flagged metric, or sample for coaching
  Stakeholders: Ankit, call-center agents, client optometry practices, patients
  Constraints: 60+ remote Filipino agents, high call volume, subjective signal is hard to measure at scale, no systematic retroactive review process despite Fathom access
- People-quality assessment (hiring and management): Evaluate whether a candidate or current team member is good for the work. The articulated framework is four-lens: routing tasks, sense-making, capacity-building, accountability. The operational read is binary: A-player (proactive, predictive, delivers ahead of ask, solves without being told, self-orients to company direction) vs. have-to-baby-them. Only a couple of people in Ankit's history have cleared the A-player bar.
  Cadence: continuous for existing team; per-stage for hiring pipeline
  Trigger: new hiring round or observed performance event
  Stakeholders: Ankit, hiring candidates, existing team, future GM and developer hires
  Constraints: no formal rubric beyond the four-lens framework, bias risk from gut feel, signal is often slow to emerge, A-player is a rare bar
- Daily thread prioritization (vibes-driven; sales-anchored): Each day and each session close, Ankit chooses which thread to work on next (sales, hiring, Bill.com, OpenBrain, websites, ad-hoc fires). Sales always wins by default because Ankit personally owns it. Everything else is selected on feel, not stated need or strategic alignment. Ankit has explicitly flagged this as his biggest operational weakness and is asking for help building a cascading objective system (annual to quarterly to weekly to daily) so he can stay focused on what matters, not what feels urgent.
  Cadence: multiple times per day plus morning re-selection
  Trigger: session close, meeting end, morning start
  Stakeholders: Ankit
  Constraints: no systematic next-day, next-week, or next-quarter planning cadence yet; risk of drift from what actually matters vs. what feels urgent; Ankit wants external help on a cascading objective system across annual, quarterly, weekly, and daily horizons

### Dependencies

The chronic dependency lock in Ankit's week is team execution failure across both CVC and MyBCAT. The team consistently does not execute on its own responsibilities, forcing Ankit to absorb work or do it himself. Which bottleneck is visible rotates. Right now it is ops supervisor coaching, which gates call-quality improvement and therefore Ankit's ability to confidently sell new practices. Historically it has been tech deploys or leadership deliverables. Other dependencies: (a) tech team delivery where Ankit routinely self-serves by building it himself, (b) AI agent run time (Claude Code and Codex cycle-time micro-waits), (c) strategy work Ankit owes himself (roll-up financial model and quarterly objectives, which keep getting deferred), and (d) a missing or unreliable accounting/bookkeeping function. Candidates respond fast, which is a non-issue. Clients approve at normal business pace. The compound lock is: supervisor coaching gap leads to an agent metrics plateau, so Ankit cannot confidently sell and revenue growth is capped.

- Team execution failure (chronic pattern across CVC and MyBCAT): Teams at both CVC and MyBCAT regularly do not execute on their own responsibilities. What is the bottleneck rotates: today ops supervisors, other times tech team deploys or leadership deliverables. The underlying dynamic is constant: Ankit ends up absorbing work, cleaning up, or doing it himself. This is the biggest chronic dependency lock in the operating model.
  Cadence: continuous
  Trigger: any handoff to the team; any assumed-but-not-monitored workstream
  Stakeholders: Ankit, CVC leadership, MyBCAT leadership, ops supervisors, tech team, direct reports
  Constraints: leadership does not lead proactively per Ankit, the bottleneck rotates between ops, tech, and leadership, and Ankit's self-absorption fallback caps his availability for strategy
- Current instance: ops supervisor coaching gap gates sales. This is today's most visible manifestation of the chronic team-execution pattern. Supervisors own agent performance but mostly lack sense-making, so they do not coach or develop. One supervisor can actually sense-make and is drowning at about 50 agents. Until that bench deepens, call-quality metrics cannot improve, which gates Ankit's ability to sell more practices with confidence. This is the compound lock on MyBCAT's growth engine right now.
  Cadence: continuous (current-state dominant)
  Trigger: any push to improve agent performance or scale sales
  Stakeholders: ops supervisors, ops leadership, 60+ agents, Ankit, sales pipeline, CVC and MyBCAT client practices
  Constraints: only one supervisor can sense-make currently, that supervisor is overloaded at about 50 agents, A-player bar is rare per the people-quality decision layer
- Tech team project delivery: Ankit self-serves as fallback. Ankit wants projects done faster. Vince is generally good, but deploys take time. When delivery drags, Ankit bypasses the team and does the project himself. This self-serve fallback scales poorly because it caps founder time.
  Cadence: project-by-project
  Trigger: Ankit assigns a project or wants a feature
  Stakeholders: Vince, tech team, Ankit, end users of the feature
  Constraints: deploy step specifically slow, self-serve fallback caps throughput as founder time gets capped
- AI agent run time (Claude Code and Codex): Throughout the day, Ankit waits on Claude Code and Codex runs to finish before entering the next prompt. This is a non-people dependency, but it is cumulative across a workday.
  Cadence: many times per day
  Trigger: every prompt cycle
  Stakeholders: Ankit, Anthropic, OpenAI
  Constraints: cycle time is outside Ankit's control, multiplexing across concurrent sessions is the current coping strategy
- Strategy work Ankit owes himself (roll-up financial model): Ankit is the upstream bottleneck on company-level strategy. A financial planning model for the roll-up scenario keeps being pushed because day-to-day work and vibes-driven prioritization crowd out deep thinking time. No one else can do this work. It ties directly to the decision-layer weakness: no annual to quarterly to weekly to daily cascade.
  Cadence: should be periodic (quarterly at minimum); currently deferred indefinitely
  Trigger: strategic inflection points (roll-up consideration, GM hire, financial planning cycle)
  Stakeholders: Ankit, future GM, leadership team, potential roll-up counterparties
  Constraints: Ankit is too busy in day-to-day work to execute, it ties back to prioritization weakness, and no one else can do this work
- Missing or unreliable accounting-bookkeeping function: There is currently no reliable accounting/bookkeeping function. Ankit's read: "we don't really have one right now, and everyone just takes too long." This blocks clean financial visibility and therefore blocks the strategy work (roll-up financial model) Ankit owes himself.
  Cadence: monthly or as needed
  Trigger: month-close, financial visibility need, strategy work
  Stakeholders: Ankit, future GM, Bill.com integration, QuickBooks, CVC finance (separate QBO account)
  Constraints: role gap, no dedicated hire, prior external accounting help has been too slow

### Institutional Knowledge

What is safe if Ankit goes dark: tech stack (Vince can run it), HubSpot contact records, AWS-resident data and MCPs, Monday.com activity, Fathom meetings indexed into AWS, and Google Drive docs. What breaks: the sales process (no documented playbook), client attention and drift management (Ankit is the attention layer; bleed starts without him), situational synthesis (what the client actually needs vs. what they said, plus a non-negotiable escalation stance), and an unenumerated library of early-warning churn signals, including ones even Ankit has not named yet. Above all, a cross-threads operating synthesis layer. Ankit's own articulation: "I'm driving the action, looking out for potholes, steering away, and driving it; that layer of tacit knowledge would be gone without me." Time-horizon read: two weeks survivable; much longer and the company "falls apart or close to it." Billing and payments is a shared ownership gap; nobody does it well, including Ankit. Knowledge-location map (company-safe): HubSpot (sales contact history), AWS and MCPs (company data, reports, dashboards), Google Drive (docs), Monday.com (target knowledge home, in transition), Fathom (meetings indexed into AWS and MCPs), Playbook MCP, MyBCAT Ops MCP. Obsidian and OB1 Personal are Ankit's personal capture, not company systems.

- Sales process (the HOW, not the contact log): The sales contact history is captured in HubSpot, and HubSpot Daily 2 automates partial outbound heuristics. The actual sales process, how Ankit qualifies, engages, moves deals, and closes, lives only in Ankit's head. If Ankit is unavailable, the new-sales channel breaks.
  Trigger: any sales activity or pipeline movement
  Stakeholders: Ankit, future GM, future sales team, HubSpot, HubSpot Daily 2 repo
  Constraints: no written sales playbook, no backup seller, succession bar is high because of persona depth
- Situational synthesis, what the client actually needs vs. what they said: Ankit translates a client's surface-level request or complaint into the real underlying need and then drives team action with non-negotiable framing. Concrete example: a client asks about lunch coverage and flags the AI bot being off. Ankit tells the team the AI bot should have been nailed down pre-launch, lunch coverage is required regardless of headcount, and "not enough people is not the point; I need a timeline, I'm going to get more people." Without this translation and stance layer, the team picks up the surface ask and drops the real issue.
  Cadence: per client escalation
  Trigger: client request or complaint arrives at ops
  Stakeholders: Ankit, ops leadership, client practices, ops supervisors, agents
  Constraints: founder-synthesis capability, not easily documented because it is situational
- Churn and risk signal library (unenumerated): Ankit detects early-warning signals that a client may be leaving and routes team behavior accordingly. Concrete example: a client visiting MyBCAT's own website often means they are considering leaving, so the team is told not to reach out because reaching out at that moment can confirm the exit. Ankit explicitly says "I don't really know what all the signals are," so the library is unenumerated even to him.
  Cadence: continuous or ambient
  Trigger: anomaly in client behavior (website visit, review tone shift, call-volume change, other)
  Stakeholders: Ankit, ops team, client practices, MyBCAT sales funnel, CVC
  Constraints: not documented, not even self-enumerated, pattern detection is partly gut-level
- Cross-threads operating synthesis, driving the action and looking out for potholes: Ankit's articulation is, "I'm driving the action, looking out for potholes, steering away, and driving it; that layer of tacit knowledge would be gone without me." This is the cross-company, cross-threads synthesis layer that holds MyBCAT and CVC together in daily operations: connecting client history, team capacity, tech readiness, and strategic direction into a single coherent read and passing non-negotiable action down to the team. It is distinct from per-client synthesis because this is the integrated operating-level layer.
  Cadence: continuous, every working day
  Trigger: any ambiguous situation, cross-team decision, or drift risk
  Stakeholders: Ankit, future GM, CVC leadership, MyBCAT leadership, ops team, tech team
  Constraints: requires full company context to perform, is not transferable without a long onboarding for a successor, and is the single most important piece of tacit knowledge in the company
- Billing and payments ownership gap (acknowledged): End-to-end billing and payments, including AR, vendor payments via Bill.com, reconciliation, and client billing flags, is a shared ownership gap. Ankit's read: "people don't do that well, including me." Partial tools exist (QuickBooks MyBCAT, QuickBooks CVC, Bill.com, mybcat-ar data, the Bill.com integration Ankit is building), but no owner drives it end-to-end.
  Cadence: monthly AR/AP; as-needed reconciliation
  Trigger: invoice due, payment due, month-close, client billing question
  Stakeholders: Ankit, future GM, future bookkeeper or accountant, Bill.com, QuickBooks
  Constraints: no owner currently, Ankit self-describes as not good at it, ties back to the missing accounting function in the dependencies layer

### Friction

The top friction is a meta-friction: the automation projects meant to reduce Ankit's load are now themselves his biggest time sink because AI bots drift and hallucinate and need babysitting. Concrete case: the website, SEO, and AEO automation drifted and Ankit had to step in. This is also the biggest risk pattern for the upcoming admin-tool builds, including invoicing, payroll, and CVC payroll now landing on him. An empirical next step Ankit proposed is to pull logs to count how many times he jumps into repos to modify or manually run things, such as on the VPS. That quantifies the babysitting tax. Secondary frictions: (a) inability to delegate internalized sense-making, which overlaps institutional-knowledge synthesis risk; (b) the team not copying the HubSpot tracking email, so the AI sales agent acts on incomplete data, now re-rated lower priority; (c) AI cycle time and prototype-as-spec tax, with multi-day build cycles that are sometimes discarded; and (d) compounding admin tax: invoicing, AR/AP, bookkeeping, and payroll for two companies now that the CVC manager is leaving.

- AI bot and run babysitting (drift and hallucination): The biggest time sink. Automations that were supposed to reduce load (website updates, SEO, AEO automation) drift and hallucinate, forcing Ankit to stop them and manually intervene. The paradox is that automation creates its own babysitting tax. This is the highest-risk pattern for the new tools Ankit is about to build for admin and payroll. Proposed measurement: pull logs to count how many times Ankit jumps into repos to modify or manually run things, such as on the VPS.
  Cadence: continuous or daily monitoring
  Trigger: automation drift, hallucinated output, or silently wrong action by an AI agent
  Stakeholders: Ankit, AI agents, Anthropic, OpenAI, downstream dependents of each automation (sales, website, admin, payroll)
  Constraints: risk of repeating the same pattern on new admin and payroll tools, no current harness enforcing eval-before-production for new AI tools
- Cannot delegate internalized sense-making: Ankit cannot currently hand off complex internalized sense-making to the team, so he absorbs it. It is unclear whether the cause is Ankit holding on, real team capability gaps, or both. This overlaps with the cross-threads operating-synthesis institutional-knowledge risk but shows up here as felt friction: founder time consumed by work the team should own.
  Cadence: continuous
  Trigger: any situation requiring multi-thread synthesis
  Stakeholders: Ankit, leadership, ops, future GM
  Constraints: overlap with institutional-knowledge layer (cross-threads synthesis), root cause ambiguous between Ankit and team
- HubSpot tracking email not copied, so the AI sales agent acts on incomplete data: When the team sends emails, they do not always copy the HubSpot tracking email address. The AI sales agent in HubSpot Daily 2 then acts on incomplete HubSpot contact history and almost sends mistakes. Ankit ends up manually verifying before the AI sends or cleaning up afterward. Ankit reclassified this as lower priority relative to the bigger frictions.
  Cadence: weekly or whenever team sends outbound
  Trigger: team member sends email without copying the tracking address
  Stakeholders: Ankit, team sending emails, HubSpot, HubSpot Daily 2 AI sales agent, prospects
  Constraints: behavior change required from human sender, AI agent trusts HubSpot as source of truth and amplifies any gap
- AI cycle time and prototype-as-spec tax: Claude Code, Codex, and MCP data retrieval take time. A full build cycle can take days. Sometimes Ankit does not know what he is building until he builds it, so there is discard tax on top of cycle-time tax.
  Cadence: daily
  Trigger: any new build Ankit starts without a tight spec
  Stakeholders: Ankit, Anthropic, OpenAI
  Constraints: spec clarity is genuinely hard for novel AI-first tools, multiplexing hides some cost but adds context-switch tax
- Admin tax, including invoicing, AR/AP, bookkeeping, and payroll for two companies: Ankit is currently doing client invoices, payment review, AR/AP, bookkeeping, and newly payroll for both MyBCAT and CVC because the CVC manager is leaving, so that load is landing on him. He plans to build tools to reduce this. Per the first friction, those tools risk becoming babysitting tax themselves, so the harness matters as much as the build.
  Cadence: weekly invoicing; monthly AR/AP and payroll; continuous light touch
  Trigger: invoice due, payment cycle, month-close, payroll cycle, CVC manager offboarding
  Stakeholders: Ankit, future GM, future bookkeeper, CVC after manager departure, MyBCAT finance
  Constraints: feedback-loop risk with AI babysitting, ties to dependency-layer missing accounting function

## SOUL

### Mandate

Use the operating rhythms, recurring decisions, dependencies, institutional knowledge, and friction above to provide concrete, triggerable help while honoring the boundaries and judgment rules below.

### Boundaries

- Respect dependency timing for team execution failure, the chronic pattern across CVC and MyBCAT.
- Respect dependency timing for the current ops supervisor coaching gap that gates sales.
- Respect dependency timing for tech team project delivery, where Ankit self-serves as fallback.
- Respect dependency timing for AI agent run time in Claude Code and Codex.
- Respect dependency timing for strategy work Ankit owes himself, including the roll-up financial model.
- Respect dependency timing for the missing or unreliable accounting-bookkeeping function.

### Decision Heuristics

- Outbound channel and message selection: Use prospect identity, location, prior contact history (cold vs. warm), one of six optometrist personas, lead source (Google review, phone complaint, job posting, or other), and HubSpot Daily 2 writing-style rules before acting. Escalate when Ankit manually injects value-adds such as a blog, podcast, or RAG snippet because the automated message is not pulling enough weight.
- Was this a good call? Use quantitative call metrics, tone and warmth, frictionlessness, patient laughter and emotional cues, unsaid-needs detection, and whether the patient request was actually addressed before acting. Escalate because no process currently exists; Fathom recordings are available but not revisited, and Ankit has flagged this as a gap to close.
- Is this person good for the role? Use routing-task capability, sense-making capability, capacity-building capability, accountability, proactivity, predictiveness, problem-solving without being told, and self-orientation to company direction before acting. Escalate when the observation count or time window before a go or no-go decision is not formalized.
- What do I work on right now or today? Use sales commitments (always first), calendar, feeling of urgency, recent build threads, and incoming fires before acting. Escalate because no current system exists and Ankit has explicitly asked for help building an annual to quarterly to weekly to daily objective cascade.

### Knowledge To Respect

- Sales process (the HOW, not the contact log): The sales contact history is captured in HubSpot, and HubSpot Daily 2 automates partial outbound heuristics. The actual sales process, how Ankit qualifies, engages, moves deals, and closes, lives only in Ankit's head. If Ankit is unavailable, the new-sales channel breaks.
- Situational synthesis, what the client actually needs vs. what they said: Ankit translates a client's surface-level request or complaint into the real underlying need and then drives team action with non-negotiable framing. Without this translation and stance layer, the team picks up the surface ask and drops the real issue.
- Churn and risk signal library (unenumerated): Ankit detects early-warning signals that a client may be leaving and routes team behavior accordingly. The library is not documented or fully enumerated even by Ankit.
- Cross-threads operating synthesis: Ankit connects client history, team capacity, tech readiness, and strategic direction into a coherent operating read, then passes non-negotiable action to the team. This integrated layer is distinct from per-client synthesis.
- Billing and payments ownership gap: End-to-end AR, vendor payments, reconciliation, and client billing flags lack a single owner. Partial tools exist, but no owner drives the process end-to-end.

### Quality Bar

Prefer concrete, triggerable help. Use the user's real rhythms, explicit dependencies, and known friction before proposing action.

## HEARTBEAT

### Daily Checks

- Back-to-back meetings as burnout trigger
  Trigger: calendar day with back-to-back meetings and no open block
  Why: Three compounding forces drive burnout: (a) sheer parallel-thread count (sales, hiring, multiple app builds, upcoming website work), (b) continuous context-switch tax, and (c) back-to-back meeting days with no block for work or downtime. Talking-to-people days specifically drain fast.

### Weekly Checks

- Ritual anchors: cortado, shower, trainer
  Trigger: wake (cortado); end of work (shower); scheduled training session (trainer)
  Why: The day is bookended by two personal rituals, brave cortado in the morning at home and hot shower at night, plus the trainer 3x/week. These are the only reliable day-shape anchors; the calendar itself is not.

### Monthly Checks

- None captured.

### Event-Driven Checks

- Concurrent AI-orchestrated workday
  Trigger: session start after morning hygiene and brave cortado
  Why: Work happens as continuous background AI execution (Claude Code and Codex sessions running all day, accessed via remote control) interleaved with live meetings, sales calls, interviews, and hiring work. No dedicated build blocks; building and people-time overlap throughout the day.
- Morning sharpness window
  Trigger: post-hygiene, post-cortado; pre-meeting-density
  Why: Cognitive sharpness is front-loaded. Hard problems (architecture, debugging, writing) land best early in the day, conditional on stress being in check. Later in the day degrades into reactive and admin capacity.
- Check dependency: team execution failure (chronic pattern across CVC and MyBCAT)
  Trigger: any handoff to the team; any assumed-but-not-monitored workstream
  Why: Ankit re-absorbs work, founder time gets capped, and strategy and growth get deferred.
- Check dependency: current ops supervisor coaching gap gates sales
  Trigger: any push to improve agent performance or scale sales
  Why: Agent metrics plateau, Ankit cannot confidently sell new practices, and revenue growth is capped.
- Check dependency: tech team project delivery, Ankit self-serves as fallback
  Trigger: Ankit assigns a project or wants a feature
  Why: Ankit's feature backlog stalls and Ankit re-absorbs the work.
- Check dependency: AI agent run time (Claude Code and Codex)
  Trigger: every prompt cycle
  Why: Micro-waits compound and attention fragments between sessions.
- Check dependency: strategy work Ankit owes himself (roll-up financial model)
  Trigger: strategic inflection points (roll-up consideration, GM hire, financial planning cycle)
  Why: Day-to-day drift continues, vibes-driven prioritization compounds, and the leadership team lacks clear marching orders.
- Check dependency: missing or unreliable accounting-bookkeeping function
  Trigger: month-close, financial visibility need, strategy work
  Why: Financial visibility degrades, strategy work cannot stand on solid data, and the roll-up model is blocked upstream.

### Dependency Watch

- Team execution failure (chronic pattern across CVC and MyBCAT): Need ownership and execution of assigned responsibilities without Ankit having to push from teams across CVC and MyBCAT, including ops, leadership, and tech, continuously.
- Current ops supervisor coaching gap gates sales: Need agent coaching, performance development, and sense-making transfer to agents from operations supervisors through ops leadership, continuously. This blocks call-quality improvement, which gates sales growth.
- Tech team project delivery, Ankit self-serves as fallback: Need shipped projects and deploys from the tech team (Vince primary; three-person team), with timing varying by project.
- AI agent run time (Claude Code and Codex): Need completed agent-run output from Anthropic and OpenAI infrastructure every prompt cycle.
- Strategy work Ankit owes himself (roll-up financial model): Need the financial planning model for a roll-up scenario and annual and quarterly strategy artifacts from Ankit as soon as possible. These gate strategic clarity across the company.
- Missing or unreliable accounting-bookkeeping function: Need closed books, AP/AR visibility, and financial reporting from an owner not yet identified, monthly and whenever strategy work requires it.
