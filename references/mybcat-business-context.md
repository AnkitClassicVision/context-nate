# MyBCAT Business Context — For Prompt Application
**Last updated: 2026-03-16**
**Sources: MyBCAT Ops RAG (73K chunks), AWS MCP, HubSpot, Monday.com, Git repos**

---

## Company Overview

**My Business Care Team (MyBCAT)** — mybcat.com — managed back-office and call center for U.S. optometry practices. Founded by Ankit Patel (industrial engineer, wife is optometrist). Born from centralizing their own practices (Classic Vision Care / CVC, Atlanta GA) using Philippines-based staff (~2022), then selling the service to other practices.

## Service Tiers

| Tier | Price | Description |
|------|-------|-------------|
| Virtual Assistant (VA) | $420/week | Client manages, trains, directs the agent |
| Inbound Call Answering | ~$480/week | Focused on phone calls |
| Remote Hospitality Center (RHC) | $600+/week | Flagship "done-for-you": inbound calls, recalls, insurance verification, scheduling, AI bot overflow, back office |
| Marketing/MSO (emerging) | Varies | SEO, content, social media, direct mail, website management |

## Key Metrics

- Revenue: ~$1.3M annualized (down from $1.7M)
- Target: $20M (MSO platform vision), $50M aspirational
- Clients: 30+ independent optometry practices
- Largest client: 30 locations (PE-backed)
- Typical client: 1-3 locations, independent
- Ideal MSO client: $1M+ annual revenue per location, 3+ sites
- Agent workforce: 60+ Filipino agents, organized in training waves (currently Wave 55)
- COGS target: ~40% of revenue

## Team Structure

**US Leadership:** Ankit Patel (CEO), Bre Dameron (VP Ops/COO), Justin Beecher (Finance), Phoebes Ilagan (Bookkeeping)

**PH Operations:** Kristine "Kay" Sta. Monica (Ops Mgr), Kei (QA/Performance), Nofa Lee (HR), Rea (L&D), Chad (Sr Lead Supervisors), Angela Frades (Supervisor)

**Tech:** Vince Casimiro (Tech Lead), Mohamed Reda (Dev), Juan Rodriguez (Dev). Agon Karakashi (departed Jan 2026).

## Technology Stack

- **Phone:** Amazon Connect + RingCentral
- **Cloud:** AWS (us-east-1), 106 Lambda functions, 10 RDS instances, 23 DynamoDB tables
- **Frontend:** React 18 + MUI, Astro, Vite
- **Backend:** Python 3.12-3.14, Node.js
- **IaC:** Terraform, GitHub Actions CI/CD
- **AI/ML:** Bedrock (call analysis), Bland AI (voice bot), Deepgram (transcription)
- **AI Development:** Claude Code (primary, 90% of work), 87+ skills, 6-7 concurrent agents
- **CRM:** HubSpot. **PM:** Monday.com. **Billing:** QuickBooks + Bill.com + Stripe
- **Secrets:** AWS Secrets Manager (217 secrets)

## Products

1. **Remote Hospitality Center** — core managed service
2. **AI Voice Agent (Bland AI)** — after-hours/overflow with human follow-up
3. **Client Portal** (portal.mybcat.com) — performance dashboards
4. **OptoSystem** (in development) — AI-native optometry EHR/CRM/Optical/Billing platform
5. **Voice Training Platform** — internal agent training
6. **Client Onboarding** (onboarding.mybcat.com) — automated setup
7. **OptometryConnect.com** — business directory for optometry professionals
8. **Marketing automation** — SEO, social media, blog, direct mail pipelines

## Data Handled (PHI)

- Patient names, phone numbers, appointment details
- Insurance information (policy numbers, co-pays, eligibility)
- Call recordings containing health information
- EHR/EMR access (agents log into client practice management systems)

## Compliance

- HIPAA required but not certified ("Will we pass an audit today? Probably not")
- SOC 2 actively being pursued (multiple consultant engagements Feb-Mar 2026)
- BAAs in place for some services

## Current Priorities (Q1 2026)

1. Proactive Schedule Management (Weekly Game Plan)
2. CARE Audit Average to 4.2+ (quality framework)
3. Client Growth Dashboard v1.0 + eliminate 120 person-hours manual work
4. Super Agent Retention Program
5. Marketing services expansion (toward MSO model)
6. SOC 2 certification
7. Move upmarket to PE-backed multi-location practices

## Known Issues (as of 2026-03-16)

**Critical:** 5+ databases internet-exposed, no MFA, credentials in Google Chat, passwords in Google Sheets
**High:** No dev environment, no DR plan, broken KPI emails, broken HubSpot→QB sync, no branching/PR strategy
**Business:** Scott Eyecare cancellation, agent turnover cascade, overdue client payments, client trust erosion from shared agents without notification
