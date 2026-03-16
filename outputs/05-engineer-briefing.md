# Prompt 5: Engineer Briefing Document — MyBCAT
**Generated: 2026-03-16 | Source: Nate's Newsletter "Your AI coding agent deleted 2.5 years of customer data"**
**For: Prospective security/DevOps engineer engagement**

---

# MyBCAT — Engineering Engagement Briefing

## Project Overview

**My Business Care Team (MyBCAT)** is a managed back-office and call center service for U.S. optometry practices. We provide remote Filipino agents who handle inbound phone calls, appointment scheduling, insurance verification, patient recalls, and back-office operations.

| Metric | Value |
|--------|-------|
| Revenue | ~$1.3M annualized (~$100-110K/month) |
| Clients | 30+ independent optometry practices |
| Agents | 60+ remote Filipino agents |
| Internal team | ~15 (US leadership + PH operations + 3-person tech team) |
| Data handled | Patient names, phone numbers, insurance info, appointment details, call recordings (PHI) |
| Compliance | HIPAA required, BAAs in place for some services, SOC 2 actively being pursued |
| How it was built | Primarily through AI coding agents (Claude Code, 6-7 concurrent flows). Founder/CEO is an industrial engineer, not a software engineer. Former tech lead (Agon) recently departed. |

**Important context:** Code review may reveal structural patterns typical of AI-generated code. This is expected and should not be alarming — the founder built a real business with real revenue using these tools.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Phone System | Amazon Connect (primary), RingCentral (secondary, synced q15m) |
| Frontend | React 18 + MUI v5 (portal), Astro (website), Vite |
| Backend | Python 3.12-3.14 (106 Lambda functions), Node.js 18/20 (secondary) |
| Databases | PostgreSQL (10 RDS instances), DynamoDB (23 tables, 1.37M contacts), Redis |
| Infrastructure | AWS us-east-1 (single account), Terraform, GitHub Actions CI/CD |
| AI/ML | AWS Bedrock (call analysis), Bland AI (voice bot), Deepgram (transcription) |
| Auth | AWS Cognito (7 user pools, no MFA currently) |
| Hosting | S3 + CloudFront, ECS Fargate (OptoSystem), Elastic Beanstalk (Metabase) |
| CRM | HubSpot, Monday.com |
| Billing | QuickBooks, Stripe, Bill.com |
| Secrets | AWS Secrets Manager (217 secrets, custom CLI tooling) |
| IaC | Terraform (state in S3 + DynamoDB lock), 19 CloudFormation stacks |

---

## Current Architecture

```
[Optometry Practices] → Phone Forwarding → [Amazon Connect]
                                               ↓
                              [Filipino Agents via Dextr Desktop]
                                               ↓
                              [Contact Trace Records + Recordings]
                                               ↓
                    [Deepgram Transcription] → [Bedrock Analysis]
                                               ↓
                              [PostgreSQL Analytics DB] → [Metabase Reports]
                                               ↓
                              [Client Portal (React/S3/CloudFront)]
                                               ↓
                              [Cognito Auth → API Gateway → Lambda]

[RingCentral Clients] → [EventBridge q15m Sync] → Same pipeline

[Bland AI Voice Bot] → After-hours/overflow → [DynamoDB] → Agent follow-up
```

**Note:** This project was built primarily through AI coding agents. The builder is not an engineer. Code review may reveal structural patterns typical of AI-generated code — this is expected.

---

## What's Working Well

- **Amazon Connect call center** — handling thousands of calls/month across 30+ clients reliably
- **AI call analysis pipeline** — Bedrock analyzes transcripts for SOP adherence, quality scores, call purpose via 20 EventBridge rules
- **Event-driven architecture** — well-designed pub/sub with EventBridge, SQS, SNS for data processing
- **Secrets management** — mature, centralized in AWS SM with custom CLI tooling (217 secrets)
- **OptoSystem (new EHR)** — the cleanest codebase: 1,991 tests, proper CI/CD with Trivy + TruffleHog scans, Terraform-managed, WAF-protected, TypeScript strict mode
- **Skills infrastructure** — 87 Claude Code skills enabling rapid AI-assisted development
- **Client portal** — serving operational dashboards to clients with Cognito auth
- **CI/CD on key repos** — mybcat-new has 7 GitHub Actions workflows (CI, SEO validation, scheduled publish, image optimization, Lighthouse, weekly audit, RAG ingest)

---

## Known Issues & Technical Debt

### Critical Security (Fix First)
| Issue | Details |
|-------|---------|
| Internet-exposed databases | 5+ RDS security groups with port 5432 open to 0.0.0.0/0 |
| No MFA | Zero of 7 Cognito pools have MFA enabled |
| No WAF on main infra | Only optosystem-staging has WAF protection |
| Credential exposure | Agents share insurance portal passwords in Google Chat plain text |
| Password management | All client passwords in Google Sheets visible to all agents |
| SSH exposure | 8+ launch-wizard-* SGs have SSH open to 0.0.0.0/0 |
| Embedded tokens | 2 repos have GitHub PATs in git remote URLs |
| n8n exposed | Port 5678 + SSH open to internet |

### Infrastructure Gaps
| Issue | Details |
|-------|---------|
| Single AWS account | No dev/prod separation. All development hits production. |
| Backup retention | 7-day RDS backups, no DR plan, no restore testing |
| Secret rotation | Only 3/217 secrets have auto-rotation |
| CF drift | 19 CloudFormation stacks, zero drift detection |
| Stale alarms | 5 alarms in ALARM state, some for 17+ months |
| Failed certificates | 2 ACM certs for optosystem.com domains failed DNS validation |

### Application Issues
| Issue | Since | Impact |
|-------|-------|--------|
| Daily KPI Email = zero emails | March 10, 2026 | No automated performance reports |
| Patient Bot scoring = 0% | September 2025 | QA scoring non-functional |
| HubSpot→QuickBooks sync broken | December 2025 | Manual invoice reconciliation |
| AI Dashboard data inaccurate | March 2026 | Client decisions on bad data |
| Materialized view stale columns | January 2026 | Incomplete analytics |

### Process Gaps
| Issue | Details |
|-------|---------|
| No branching strategy | All code pushed directly to main (only 1 merged PR across all repos) |
| No code review | No branch protection or PR approval gates on any repository |
| No tests (most repos) | Only OptoSystem has automated tests (1,991). Other 75 repos = zero. |
| Knowledge transfer risk | Former tech lead departed Jan 2026, 3-person team still ramping |
| 39 unversioned projects | Active directories with no git repository at all |

---

## Scope of Engagement

### What We Need (Priority Order)
1. **Security hardening** — close internet-exposed databases, enable MFA, deploy WAF, audit for prior unauthorized access
2. **HIPAA gap assessment** — identify what's missing, especially around PHI in call recordings and insurance data handling
3. **Infrastructure review** — assess single-account setup, recommend dev/prod separation, improve backup and DR
4. **CI/CD hardening** — branch protection, automated testing gates, rollback procedures
5. **SOC 2 readiness support** — we're already engaging compliance consultants

### What's Out of Scope (We Continue with AI Agents)
- New feature development on client portal
- OptoSystem development (already has proper CI/CD and testing)
- Marketing automation and SEO tooling
- Content, blog, and social media systems

### Budget/Timeline
- **Short-term:** 2-4 week engagement for security hardening and infrastructure review
- **Ongoing:** Possible relationship for SOC 2 support and DevOps maturity
- **Urgency:** Database exposure is the highest priority

---

## Key Questions for the Engineer

1. "After reviewing our security groups and network configuration, has any unauthorized access already occurred? What should we check in CloudTrail and RDS logs?"
2. "Given that we handle PHI and are pursuing SOC 2, what's the minimum viable security posture we need in the next 30 days?"
3. "Our former tech lead recommended a separate dev AWS account. What's the fastest path to environment isolation without disrupting current operations?"
4. "What changes would make it easier for our team to keep building with AI coding agents after you're done? We want guardrails, not gates."
5. "Is our current architecture fundamentally sound, or are there structural problems that need rearchitecting?"

---

## Access & Resources

| Resource | Location | Access Method |
|----------|----------|---------------|
| Source code | GitHub (`AnkitClassicVision`, 71 repos) | Org invite |
| AWS Console | us-east-1, account 533267039664 | SSO (AWSReservedSSO_AdministratorAccess) |
| Architecture doc | `opto_system_software/docs/plans/2026-02-15-optometry-platform-design.md` | Git |
| Tech handover | Fathom recordings (Jan 6-15, 2026) | Fathom invite |
| Ops knowledge base | 1,126 docs, 73K chunks (Fathom, Monday, Drive, Chat) | MCP server |
| Project instructions | 90+ CLAUDE.md files across repos | Git |

---

## What to Expect

When you bring in an engineer, here's what will happen:

- **They'll find things you didn't know about.** The internet-exposed databases are the ones we found — there may be more. AI agents optimize for "code that works" and don't proactively raise security concerns.
- **They may recommend restructuring things that currently work.** Your event-driven architecture is solid conceptually, but implementation patterns may not scale 10x.
- **They'll immediately flag the single-account setup.** Every experienced AWS engineer will.
- **This is exactly why you're hiring them.** You did the hard part — you built a real business serving real clients with real revenue. The operational skills that got you here are impressive. Security and infrastructure hardening is what the engineer brings. Your job: prioritize what's urgent (exposed DBs, MFA, credentials) vs. what can wait (CI/CD, drift detection, release tagging).

---

## Questions to Ask Engineer Candidates

1. "Have you worked with AI-generated codebases before? What patterns do you typically find?"
2. "What's your experience with HIPAA compliance in AWS environments specifically?"
3. "Show me an example of a security hardening project for a company at our stage (~$1M revenue, small team, AWS)."
4. "How do you feel about working alongside AI coding agents? We're not stopping — we need guardrails."
5. "What's your availability for the next 30 days? Our database exposure is urgent."
