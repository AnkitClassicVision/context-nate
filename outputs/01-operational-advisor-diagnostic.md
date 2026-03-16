# Prompt 1: Operational Advisor Diagnostic — MyBCAT
**Generated: 2026-03-16 | Source: Nate's Newsletter "Your AI coding agent deleted 2.5 years of customer data"**
**Data sources: AWS MCP (102 tools), MyBCAT Ops RAG (73K chunks), Git repos (76 repos), infrastructure audit**

---

## Scoring Table

| Dimension | Score | Assessment |
|-----------|-------|------------|
| **Version Control** | 3/5 | Git across 76 repos with systematic AI co-author commits (651/850 recent commits tagged), but no branching strategy, no PRs (only 1 merged PR found across all repos), no code review gates, no release tags. Work goes direct to main. |
| **Context Hygiene** | 4/5 | Runs 6-7 concurrent Claude Code agents with 87+ domain-specific skills that scope context per task. Sophisticated multi-agent approach provides natural session isolation. Skills have structured sub-files (routing docs, API refs, testing guides). |
| **Agent Memory** | 4/5 | 90+ CLAUDE.md files, 87 skills with structured sub-files, 100+ project-specific instruction sets. Some repos very thorough (opto_system: 430 lines, hubspot-daily-2: 688 lines). But mybcat-new (most active repo, 512 commits) has NO rules file, and some files exceed the recommended 100-line limit. |
| **Blast Radius Discipline** | 2/5 | No staging/dev AWS environment — all development hits production in a single AWS account (533267039664). No branching strategy means every push to main is live. Departing tech lead explicitly warned: "Be careful on database actions, because they might be irreversible." Multi-agent approach breaks work into pieces but no infrastructure safety net exists. |
| **Production Readiness** | 2/5 | 5+ PostgreSQL databases exposed to `0.0.0.0/0` on port 5432. No MFA on any of 7 Cognito user pools. No HIPAA certification despite handling PHI. No disaster recovery plan. Only 7-day RDS backup retention. Stale alarms ignored for 17+ months. But: secrets management is mature (217 secrets in AWS SM), some CloudWatch coverage exists, WAF on OptoSystem. |

---

## Biggest Risk

**Production Readiness is your most urgent gap**, and it's not close. You have at least 5 RDS databases with security groups open to the entire internet on port 5432 (`connectanalyticsdb-sg`, `voice-training-db-sg`, `rds-ec2-1`, default VPC SG, `launch-wizard-3`). Your `Connecteams-VPC` security group allows ALL protocols from `0.0.0.0/0`. You handle PHI (patient names, insurance info, call recordings with health data) across 30+ optometry clients, and you told SOC 2 consultants: *"Will we pass an audit today? Probably not."* A single database scan by an attacker could expose your 1.37M contact records and every client's patient data. This isn't theoretical — your own team acknowledged agents are sharing insurance portal credentials in plain text in Google Chat.

---

## Your Action Plan

### Today (next hour)
Restrict all `0.0.0.0/0` rules on RDS security groups to your VPC CIDR (`172.31.0.0/16`) or specific source security groups. Go to AWS Console > EC2 > Security Groups. The groups to fix immediately:
- `connectanalyticsdb-sg` (port 5432 open to internet)
- `voice-training-db-sg` (port 5432 open to internet)
- `rds-ec2-1` / mybcat-scribe (port 5432 open to internet)
- `launch-wizard-3` (port 5432 open to internet)
- Default VPC SG `sg-0909201551a067640` (ports 5432 + 8000 open)
- `Connecteams-VPC-security-group` (ALL traffic from 0.0.0.0/0)
- `launch-wizard-1` (ALL traffic from 0.0.0.0/0)

This takes 15 minutes and eliminates the most critical attack surface.

### This Week
1. Enable MFA on `mybcat-client-portal-production` Cognito user pool (TOTP minimum)
2. Set up branch protection on top 5 repos (`opto_system_software`, `mybcat-new`, `sales_agent`, `mybcat_brain`, `local-seo-automation`) requiring review before merge to main
3. Create a CLAUDE.md for `mybcat-new` (your most active repo with 512 commits and zero rules file)
4. Complete PassBolt migration to get agent passwords out of Google Sheets

### This Month
Create a separate AWS account for development using AWS Organizations. Move all non-production workloads there. This is the single structural change your departing tech lead recommended first: *"If I would go back in time, a year and a half when I joined, I would implement this from the get-go."* Combined with your active SOC 2 pursuit, this gives you environment isolation that both protects production and satisfies auditors.

---

## Next Priority
**Blast Radius Discipline** — the combination of no staging environment and no branching strategy means every Claude Code commit is a live deployment. Once you have the dev account, establish the rhythm: small task → test → commit → repeat. Your multi-agent approach already breaks work into pieces; you just need the infrastructure to catch mistakes before they hit production.
