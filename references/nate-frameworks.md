# Nate's Key Frameworks & Concepts
**Source: Nate's Newsletter (natesnewsletter.substack.com)**
**504 posts indexed, 73K+ embedded chunks in MCP**

---

## Core Frameworks

### 1. The Five Supervisory Skills for AI-Assisted Building (2026-03-16)
Non-technical builders need these to manage AI coding agents safely:
1. **Version Control** — Git as a time machine. Commit before every change.
2. **Context Window Management** — Agents degrade mid-session. Fresh sessions per task.
3. **Rules Files** — CLAUDE.md/.cursorrules give persistent memory across sessions.
4. **Blast Radius Discipline** — Small tasks, test, commit, repeat. Never sweeping changes.
5. **Production Readiness** — Error handling, security, scale that agents won't raise on their own.

### 2. The Scaling Expertise Framework (2025-10-15)
Universal pattern for 20x+ output with AI:
- **The bottleneck was never expertise — it was the documentation layer**
- **Four inputs:** Role, Audience, Goal, Constraints + raw expertise
- **AI handles translation** (structure, format, polish). You handle judgment (accuracy, strategy, relationships).
- **The 80-20 threshold:** AI gets 80% fast. Your expertise handles the 20% requiring judgment.
- **Context is your multiplier:** Better articulation → better output.
- Works for every domain: legal, medical, trades, ecommerce, real estate, engineering.

### 3. Rejection as a Competency (2026-03-10)
- **Rejections compound, prompts are disposable.** Every domain expert correction creates a constraint that didn't exist before.
- **Three dimensions:** Recognition (seeing what's wrong), Articulation (explaining why), Encoding (making it persistent)
- **The Taste Preferences system:** Auto-capture correction patterns → store as preferences → compound over time
- **The seed corn problem:** 67% collapse in entry-level tech hiring eliminates the pipeline that produces the experts AI depends on.

### 4. The Jagged Frontier is Smoothing (2026-03-11)
- The "jagged frontier" (where AI excels vs. fails) was a measurement artifact
- Coding agents + harnesses are smoothing the frontier by delegating sub-tasks to verification loops
- Map where YOUR work sits on the spectrum: which tasks are already smooth, which are still jagged

### 5. Harness > Model (2026-03-06)
- Same model scored 78% vs 42% depending on the harness wrapping it
- Claude Code and Codex bet on different harness architectures
- Your team compounds one harness approach every week — audit which one

### 6. Intent Engineering (2026-02-24)
- Klarna saved $60M but broke its company
- The missing layer between prompts and outcomes is **intent engineering**
- AI execution cost dropped 10x, but intent misalignment causes 10x the damage

### 7. The Verification Gap (2026-01-07)
- AI agents can generate but can't reliably verify their own output
- "Dumb agents with smart orchestration" > "smart agents with no oversight"
- Agent loops only converge when verification is externalized

### 8. The Specification Gap (2026-01-21)
- AI produces impressive-looking output with fundamental problems when specs are vague
- The gap between what you meant and what you said is where failures live
- Tool-shaped AI (does what you say) vs Colleague-shaped AI (interprets what you mean)

### 9. The Composability Era (2025-12-31)
- Anyone can now build a UI. The interface layer has opened up.
- This changes the economics of software: the hard part shifts from building to operating

### 10. AI Memory / Open Brain (2026-03-02, 2026-03-13)
- Every AI starts from zero each new chat — this is the biggest productivity loss
- Open Brain: a $0.10/month, 45-minute fix using Supabase for persistent AI memory
- Extensions that compound: household knowledge, job hunt context, taste preferences

---

## Nate's Prompt Structure (Universal Pattern)

```
<role>
[Who the AI should be — specific expertise and perspective]
</role>

<instructions>
[Step-by-step workflow — numbered, with clear sequencing]
[Interview-style information gathering before output]
[Explicit output structure defined]
</instructions>

<output>
[Exact deliverable format — tables, sections, word counts]
</output>

<guardrails>
[What NOT to do — specific prohibitions]
[Quality constraints — keep under X lines, no jargon, etc.]
[When to escalate vs. handle]
</guardrails>
```

---

## Key Nate Quotes

> "Your app will run whether or not it's maintainable, secure, or recoverable from disaster."

> "The creative leap comes first, the operational knowledge comes later, and the gap between the two is where people get hurt."

> "Every time a domain expert looks at AI output, identifies what's wrong, and explains why, they produce a constraint that didn't exist before. That constraint is more valuable than the output."

> "The expertise is the valuable thing. The documentation was the constraint. AI removed it."

> "Dumb agents mean smart orchestration."
