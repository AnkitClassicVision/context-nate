<!-- MYBCAT-GUIDELINES-START -->
<!-- DO NOT EDIT BETWEEN THESE MARKERS - managed by mybcat-sync-guidelines -->
<!-- Last synced: 2026-03-16 18:22:53 -->
## MyBCAT Universal Rules
## Symlink into any repo serving MyBCAT infrastructure or client operations
## Grown from real incidents — every line traces to a documented problem

## Project Context
MyBCAT is a managed back-office and call center service for 30+ U.S. optometry practices.
We handle PHI (patient names, insurance, call recordings). HIPAA compliance is mandatory.
Built primarily with AI coding agents (Claude Code). Founder is not a software engineer.
Revenue: ~$1.3M annualized. 60+ remote Filipino agents. 3-person tech team.

## Architecture
- AWS us-east-1 single account (533267039664). No dev/prod separation yet.
- Phone: Amazon Connect (primary) + RingCentral (secondary, synced q15m via EventBridge).
- Analytics DB: connect-analytics-db (PostgreSQL t4g.medium). DynamoDB Contacts: 1.37M items.
- Auth: Cognito (7 pools). CRM: HubSpot. PM: Monday.com. Billing: QuickBooks + Bill.com + Stripe.
- Secrets: AWS Secrets Manager (217 secrets). Use `secret-store` CLI. Never hardcode.
- CI/CD: GitHub Actions with OIDC auth. Manual trigger — never auto-deploy to prod.
- IaC: Terraform (state in S3 + DynamoDB lock). Some legacy CloudFormation stacks.

## Code Standards
- Python: type hints, f-strings, logging (not print). Lambda handlers return proper status codes.
- TypeScript: strict mode. Conventional commits (feat:, fix:, chore:, docs:, ci:).
- Every API endpoint includes error handling with user-friendly messages. No raw errors to users.
- Never log patient names, emails, insurance IDs, phone numbers, or payment info.
- All DB queries use parameterized statements. No string interpolation in SQL.
- Commit after each logical unit of work. Do not batch unrelated changes.

## Things You Must Not Do (Each line = a real incident)
- Do not modify security groups without explicit approval. We had 5+ DBs exposed to 0.0.0.0/0.
- Do not create "launch-wizard-*" SGs via console. Use Terraform exclusively.
- Do not add 0.0.0.0/0 ingress rules to ANY security group. Scope to VPC CIDR or specific SGs.
- Do not share credentials in chat, comments, or code. Agents posted insurance passwords in Google Chat.
- Do not run DB migrations without a snapshot. We have no rollback procedures.
- Do not modify DynamoDB Contacts table structure without approval (1.37M records, high blast radius).
- Do not push directly to main on repos with CI/CD. Branch + PR required.
- Do not deploy infrastructure without `terraform plan` review first.
- Do not use Bland AI non-versioned pathway endpoint. Edge labels don't persist. Use versioned endpoint.

## Working Style
- If a task will touch more than 3 files, propose a plan and wait for approval.
- Assume every table will hold hundreds of thousands of records. Add indexes proactively.
- Before destructive operations (DELETE, DROP, TRUNCATE, SG changes), state what you're about to do.
- If your agent has been working more than 5 minutes without results, stop and check.
- Fresh session per logical task. Do not let sessions run indefinitely.

## Security (MANDATORY — we handle PHI)
- All patient-facing endpoints require Cognito auth. No anonymous access to PHI.
- Row-level security: users only see data scoped to their tenant/client.
- Never store PHI in S3 without encryption (SSE-S3 minimum, KMS preferred).
- All new RDS instances use Terraform-managed SGs restricted to VPC CIDR.
- Rate-limit all public-facing API Gateway endpoints.
- Never expose internal tools (n8n, Metabase) to 0.0.0.0/0. VPN or office IP only.

## Security Audit Additions (2026-03-16)
- All Cognito user pools must have MFA enabled (TOTP minimum).
- Never share credentials via chat, email, or code. Use PassBolt or AWS Secrets Manager.
- All public endpoints must have WAF with rate limiting.
- DynamoDB: use Query with GSI, never Scan on tables >100K items.
- RDS backup retention minimum 35 days. Snapshot before every migration.
- Never embed GitHub tokens in git remote URLs. Use SSH or credential helpers.
- Run CloudFormation drift detection monthly.
- All repos must have CI that runs lint + build before merge to main.

<!-- MYBCAT-GUIDELINES-END -->
