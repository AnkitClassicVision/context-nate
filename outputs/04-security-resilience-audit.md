# Prompt 4: Security & Resilience Audit — MyBCAT
**Generated: 2026-03-16 | Source: Nate's Newsletter "Your AI coding agent deleted 2.5 years of customer data"**
**Audit data: 46 security groups, 7 Cognito pools, 217 secrets, 36 alarms, 19 CF stacks, 10 RDS instances, 23 DynamoDB tables, 106 Lambda functions**

---

## Category 1: Security

### CRITICAL Priority

**S1. Five+ databases directly accessible from the internet**
- **Risk:** Anyone with a port scanner (Shodan, Censys) can find your PostgreSQL databases on port 5432 and attempt brute-force login. Success means access to 1.37M contact records, patient insurance data, and call analytics for all 30+ optometry clients. Under HIPAA, this would require breach notification to every affected patient.
- **How to check:** AWS Console → EC2 → Security Groups → search `connectanalyticsdb-sg` → Inbound rules tab. If `0.0.0.0/0` appears on port 5432, it's exposed. Repeat for: `voice-training-db-sg`, `rds-ec2-1`, default VPC SG, `launch-wizard-3`.
- **Fix prompt:** See Task Decomposer (Output 03) — Steps 2-5.
- **Priority:** CRITICAL

**S2. No MFA on any Cognito user pool**
- **Risk:** Client portal users (your optometry practice clients) log in with password only. A phished or guessed password gives full access to that client's call data, agent performance, and patient-adjacent information. With 30+ practices, the attack surface is significant.
- **How to check:** AWS Console → Cognito → User Pools → `mybcat-client-portal-production` → Sign-in experience → Multi-factor authentication. If "Off," there's no MFA.
- **Fix prompt:** *"Enable MFA on the mybcat-client-portal-production Cognito user pool. Set MFA to 'Optional' with TOTP (authenticator app) as the method. Update the client portal login flow to prompt users to set up MFA on their next login. Do NOT make it mandatory yet — let clients opt in first, then make it required after 30 days."*
- **Priority:** CRITICAL

**S3. Insurance credentials shared in plain text in Google Chat**
- **Risk:** Chat logs show agents posting usernames and passwords for insurance portals (Availity, UHC/Spectera, Davis Vision, Trizetto) directly in chat channels. Anyone with chat history access — including agents who later leave — can harvest these credentials.
- **How to check:** Search Google Chat spaces (e.g., "Eyecare and Eyewear Aventura") for keywords "password," "login," "username." If portal credentials appear in messages, this is confirmed.
- **Fix prompt:** *"Create an SOP document titled 'Credential Security Policy.' State: (1) No credentials may be shared via chat, email, or messaging, (2) All credentials must be stored in PassBolt, (3) Agents found sharing credentials in chat receive an immediate warning, (4) Supervisors must audit chat channels weekly for credential leaks."*
- **Priority:** CRITICAL

**S4. Agents have direct access to all client passwords**
- **Risk:** Passwords stored in Google Sheets visible to all agents. With frequent turnover (6+ agents departed recently: Jessa, Julie, Ezza, Red, Leah, Rosie), each departing agent retains knowledge of credentials. Combined with S3, this creates a significant insider threat.
- **How to check:** Ask Kristine or Bre: "Can a regular agent open the Google Sheet and see client system passwords right now?" If yes, confirmed.
- **Fix prompt:** *"Set up PassBolt password manager. Migrate all client credentials from Google Sheets. Configure per-account access scoping so agents only see passwords for their assigned clients. Delete the Google Sheets password files after migration is verified. Set a 90-day rotation policy for all shared credentials."*
- **Priority:** CRITICAL

### HIGH Priority

**S5. No WAF on main MyBCAT infrastructure**
- **Risk:** Only `optosystem-staging` has WAF protection. The Elastic Beanstalk ALB (Metabase), client-portal API Gateway, and other public endpoints are unprotected against SQL injection, XSS, credential stuffing, and DDoS.
- **How to check:** AWS Console → WAF & Shield → Web ACLs. If only `optosystem-staging` appears, your main infrastructure is unprotected.
- **Fix prompt:** *"Create a WAF Web ACL named 'mybcat-main-waf'. Attach AWS Managed Rules: AWSManagedRulesCommonRuleSet, AWSManagedRulesKnownBadInputsRuleSet, AWSManagedRulesSQLiRuleSet. Add a rate-limiting rule at 2000 requests per 5 minutes per IP. Associate it with the client-portal API Gateway and the Elastic Beanstalk ALB."*
- **Priority:** HIGH

**S6. GitHub PATs embedded in git remote URLs**
- **Risk:** `mybcat-new` and `mybcat-social-content-automation` have Personal Access Tokens visible in plaintext in `.git/config`. If these repos are shared, forked, or the config is viewed, the tokens are exposed.
- **How to check:** Run `git remote -v` in those repo directories. If the URL contains `ghp_` followed by a token string, it's exposed.
- **Fix prompt:** `git remote set-url origin https://github.com/AnkitClassicVision/mybcat-new.git` (without the token). Revoke exposed tokens on GitHub → Settings → Developer settings → Tokens. Use SSH keys or `gh auth login` instead.
- **Priority:** HIGH

**S7. n8n automation tool exposed to internet**
- **Risk:** `Mo-n8n-firewall` exposes n8n (port 5678) and SSH to `0.0.0.0/0`. n8n workflows likely contain embedded API keys and automation credentials.
- **How to check:** AWS Console → EC2 → Security Groups → `Mo-n8n-firewall`. Check if 5678 and 22 are open to 0.0.0.0/0.
- **Fix prompt:** *"Restrict Mo-n8n-firewall inbound rules: port 5678 only from office IP [YOUR_IP/32]. Remove SSH 0.0.0.0/0 entirely — use SSM Session Manager for access instead."*
- **Priority:** HIGH

**S8. SSH open to internet on 8+ security groups**
- **Risk:** All `launch-wizard-*` groups (1-11) have SSH (port 22) open to `0.0.0.0/0`. This is the #1 most scanned port on the internet.
- **How to check:** AWS Console → EC2 → Security Groups → filter by "launch-wizard". Check inbound rules for port 22 → 0.0.0.0/0.
- **Fix prompt:** *"For all launch-wizard-* security groups, remove SSH rules with source 0.0.0.0/0. Install and configure AWS SSM Session Manager as the replacement for SSH access. This eliminates the need for SSH entirely."*
- **Priority:** HIGH

---

## Category 2: Error Handling

### HIGH Priority

**E1. Daily KPI Email Report sending zero emails (since March 10, 2026)**
- **Risk:** The report system appears completely non-functional — 0 agent emails, 0 supervisor emails, 0 failures logged for 7 consecutive days. Supervisors and clients aren't getting performance data, making quality management impossible.
- **How to check:** Check "Postcall Test Space" Google Chat. Look for daily KPI report messages. Every entry from March 10-16 shows all zeros.
- **Fix prompt:** *"Debug the Daily KPI Email Report Lambda. Check CloudWatch logs for errors. Verify: (1) the EventBridge trigger rule is enabled, (2) the SES sending identity is verified and not sandboxed, (3) the recipient list query returns actual agents/supervisors, (4) the KPI data query returns non-null results. The system has been sending zero emails for 7 days."*
- **Priority:** HIGH

**E2. HubSpot-to-QuickBooks sync broken (since December 2025)**
- **Risk:** Invoice sync failures are causing overdue invoice accumulation, requiring manual reconciliation by Phoebes. Revenue recognition is delayed and billing errors are compounding.
- **How to check:** Ask Phoebes: "Are HubSpot invoices syncing automatically to QuickBooks, or are you entering them manually?"
- **Fix prompt:** *"Debug the HubSpot-to-QuickBooks sync. Check OAuth token validity for both services. Verify field mapping hasn't drifted. Check for error logs in the sync Lambda or workflow. The sync has been broken since December 2025 — 3+ months of manual workaround."*
- **Priority:** HIGH

**E3. AI Dashboard data inaccuracy**
- **Risk:** Bre was assigned to "Email Ankit AI dashboard data issues/corrections" on March 11, 2026. Clients making decisions based on inaccurate analytics data erodes trust and could lead to incorrect operational changes.
- **How to check:** Open the AI dashboard. Compare 3-5 data points against raw Amazon Connect metrics for the same period. If they don't match, confirmed.
- **Fix prompt:** *"Audit the AI dashboard data pipeline. Check the materialized view refresh schedule. Compare materialized view data against raw Connect CTR data for the past 7 days. New columns were added that read directly from different tables — verify they're pulling from the correct sources. The previous tech lead flagged this needs rechecking."*
- **Priority:** HIGH

### MEDIUM Priority

**E4. Patient Bot scoring always returns 0% (since September 2025)**
- **Risk:** QA scoring tool can't evaluate agent performance, making quality assurance entirely manual. Reported 6 months ago, still unfixed.
- **How to check:** Open Patient Bot scoring. Run a test evaluation. If score = 0%, confirmed.
- **Fix prompt:** *"Investigate the Patient Bot scoring function. The algorithm always returns 0%. Check for: division-by-zero in scoring calculation, empty transcript input, misconfigured scoring criteria weights, or a broken data pipeline feeding the scorer."*
- **Priority:** MEDIUM

**E5. Amazon Connect access failures for Philippines agents**
- **Risk:** Multiple agents unable to access Connect due to ISP changes and mobile hotspot usage. Four reports in one day triggered escalation. Affects client service delivery.
- **How to check:** Ask supervisors: "How many agents had Connect access issues this week?" If more than 2, this is a recurring pattern.
- **Fix prompt:** *"Create an SOP for Philippines agent connectivity. Document: (1) required ISP settings, (2) VPN configuration if needed, (3) troubleshooting steps for common ISP issues, (4) escalation path when self-service fails. Track connectivity incidents on Monday.com to identify ISP patterns."*
- **Priority:** MEDIUM

---

## Category 3: Scale Readiness

### HIGH Priority

**R1. Only 7-day RDS backup retention, no DR plan**
- **Risk:** If data corruption or accidental deletion is discovered after 7 days, there's no recovery point. No cross-region replication means a us-east-1 outage takes everything down. The departing tech lead noted: "Database rollback, we don't have a rollback right now. I didn't see any backup procedures."
- **How to check:** AWS Console → RDS → select `connect-analytics-db` → Maintenance & Backups. If retention = 7 days with no documented restore procedure, confirmed.
- **Fix prompt:** *"Increase RDS backup retention to 35 days for connect-analytics-db and optosystem-staging. Create a manual snapshot before any schema migration. Document the restore procedure in a runbook. Test a restore to a temporary instance to verify backups work."*
- **Priority:** HIGH

**R2. No staging/dev environment**
- **Risk:** All development happens against production. The departing tech lead's #1 recommendation was environment separation. Any AI-generated code deployed through CI/CD goes straight to production.
- **How to check:** AWS Console → check if there's only one account. If all Lambda functions, databases, and services exist in the same account, confirmed.
- **Fix prompt:** *"Create an AWS Organization with a dev sub-account. Set up cross-account roles for deployment. Migrate non-production Lambda functions and a clone of the analytics DB to the dev account. Update CI/CD to deploy to dev first, then promote to prod after manual approval."*
- **Priority:** HIGH

### MEDIUM Priority

**R3. DynamoDB Contacts table optimization**
- **Risk:** 1.37M items and growing. If queries use Scan instead of Query with proper GSIs, costs and latency will increase linearly with table size.
- **How to check:** AWS Console → DynamoDB → Contacts → Capacity. Check for throttled reads. Check Lambda functions for Scan operations.
- **Fix prompt:** *"Review the DynamoDB Contacts table (1.37M items). List all GSIs. Search Lambda functions for Scan operations on this table. Replace any Scan with Query using appropriate GSI. Add GSIs for access patterns currently using Scan."*
- **Priority:** MEDIUM

**R4. Only 3 of 217 secrets have rotation**
- **Risk:** 214 secrets (including database credentials, API keys, and Stripe keys) never rotate. A leaked credential remains valid indefinitely.
- **How to check:** AWS Console → Secrets Manager → filter for "Rotation enabled." If only 3 (all RDS-managed), confirmed.
- **Fix prompt:** *"Enable automatic rotation for all RDS database credentials in Secrets Manager. For API keys, create a quarterly manual rotation reminder on Monday.com. Audit secrets with empty 'last_accessed' dates — these may be orphaned and should be deleted."*
- **Priority:** MEDIUM

**R5. CloudFormation drift unchecked**
- **Risk:** 19 stacks, all `NOT_CHECKED`. Console changes may have diverged from declared infrastructure. Drift means your IaC no longer represents reality.
- **How to check:** AWS Console → CloudFormation → select any stack → Stack actions → Detect drift.
- **Fix prompt:** *"Run drift detection on all 19 CloudFormation stacks. Document any drifted resources. For each drift, decide: update template to match reality, or revert resource to match template. Add a monthly drift-check reminder to Monday.com."*
- **Priority:** MEDIUM

**R6. No automated testing in most CI/CD**
- **Risk:** Only `opto_system_software` has tests (1,991). The other 75 repos ship without verification. A syntax error can break production.
- **How to check:** GitHub → Actions tab for major repos. If only opto_system_software has test steps, confirmed.
- **Fix prompt:** *"Add a CI workflow to mybcat-new, sales_agent, and mybcat_brain: lint check + build verification on every push to main. For Python repos, add `python -m py_compile` for all .py files. For JS/TS repos, add `npm run build`. This catches syntax errors before deployment."*
- **Priority:** MEDIUM

---

## Rules File Additions

Paste these into your universal CLAUDE.md:

```markdown
## Security Audit Additions (2026-03-16)
- Never create a security group with 0.0.0.0/0 inbound on any port. Scope to VPC CIDR or specific SGs.
- All Cognito user pools must have MFA enabled (TOTP minimum).
- Never share credentials via chat, email, or code. Use PassBolt or AWS Secrets Manager.
- All public endpoints must have WAF with rate limiting.
- DynamoDB: use Query with GSI, never Scan on tables >100K items.
- RDS backup retention minimum 35 days. Snapshot before every migration.
- Never embed GitHub tokens in git remote URLs. Use SSH or credential helpers.
- Run CloudFormation drift detection monthly.
- All repos must have CI that runs lint + build before merge to main.
- Internal tools (n8n, Metabase) must never be exposed to 0.0.0.0/0.
```

---

## Red Lines — You Need a Professional Engineer

1. **HIPAA compliance with PHI in call recordings.** You handle patient health information. Leadership said "Will we pass an audit today? Probably not." A HIPAA compliance specialist + security engineer are needed — not an AI agent.

2. **Internet-exposed databases + potential breach assessment.** A professional should audit CloudTrail and RDS logs for any unauthorized access that may have already occurred while databases were exposed. HIPAA may require breach notification.

3. **SOC 2 certification.** Already in consultant conversations. Cannot be AI-driven.
