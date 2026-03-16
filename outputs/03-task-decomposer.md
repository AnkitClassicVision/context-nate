# Prompt 3: Task Decomposer — Close Internet-Exposed Databases
**Generated: 2026-03-16 | Source: Nate's Newsletter "Your AI coding agent deleted 2.5 years of customer data"**
**Target: Most critical security fix identified in MyBCAT infrastructure audit**

---

## Blast Radius Assessment

This change touches **AWS security groups** controlling network access to 5+ RDS databases and several EC2 instances. Blast radius is **MEDIUM-HIGH**: if done incorrectly, legitimate Lambda functions, Metabase, or the client portal could lose database connectivity. Every client relying on call analytics, the voice training platform, and the scribe service would be affected. However, each security group can be modified independently, making this safely decomposable.

**Areas touched:** Security groups (12-15), RDS connectivity, Lambda→RDS paths, Metabase→RDS path, VPC networking
**Overall risk level:** Medium-High (each step is low risk individually, but incorrect changes could break production for all 30+ clients)
**Estimated total blast radius:** 8-12 security groups, but only 1-3 per step

---

## Step-by-Step Sequence

### Step 1: Snapshot Current State
→ **Give your agent:** "List all AWS security groups that have inbound rules allowing 0.0.0.0/0 on any port. For each one, show: group ID, group name, the port, the protocol, and what resource it's attached to (RDS, EC2, etc). Output as a markdown table. Save to security-group-audit-2026-03-16.md."

→ **Test it:** Review the table. Confirm it lists at minimum: `connectanalyticsdb-sg`, `voice-training-db-sg`, `rds-ec2-1`, default VPC SG, `launch-wizard-3`, `launch-wizard-1`, `Connecteams-VPC-security-group`, `Mo-n8n-firewall`.

→ **If it works:** Save the output as your audit baseline — you'll need this for SOC 2.

→ **If it breaks:** No risk — this is a read-only operation.

---

### Step 2: Close PostgreSQL on `connectanalyticsdb-sg` (HIGHEST RISK)
→ **Give your agent:** "Modify the security group `connectanalyticsdb-sg` to replace the 0.0.0.0/0 inbound rule on port 5432 with an inbound rule allowing port 5432 from VPC CIDR 172.31.0.0/16 only. Use the AWS CLI. First describe the current rules, then make the change."

→ **Test it:** Open portal.mybcat.com. Check that call analytics dashboards load with data. Open Metabase — verify reports still run. Wait 5 minutes and check again.

→ **If it works:** `git add . && git commit -m "fix: restrict connectanalyticsdb-sg to VPC CIDR only"`

→ **If it breaks:** Re-add the 0.0.0.0/0 rule via AWS Console while you investigate which service connects from outside the VPC. Run `aws ec2 describe-network-interfaces --filters Name=group-id,Values=<sg-id>` to see what's attached.

---

### Step 3: Close PostgreSQL on `voice-training-db-sg`
→ **Give your agent:** "Modify security group `voice-training-db-sg` to replace the 0.0.0.0/0 inbound rule on port 5432 with VPC CIDR 172.31.0.0/16 only."

→ **Test it:** Open training.mybcat.com. Load a training module. Submit a test response. Confirm it saves and loads correctly.

→ **If it works:** `git add . && git commit -m "fix: restrict voice-training-db-sg to VPC CIDR only"`

→ **If it breaks:** Revert via AWS Console. Check if the training app connects from outside VPC.

---

### Step 4: Close PostgreSQL on `rds-ec2-1` (mybcat-scribe)
→ **Give your agent:** "Modify security group `rds-ec2-1` to replace 0.0.0.0/0 on port 5432 with VPC CIDR 172.31.0.0/16."

→ **Test it:** Open scribe.mybcat.com. Test the scribe functionality. Verify data loads and saves.

→ **If it works:** `git add . && git commit -m "fix: restrict rds-ec2-1 SG to VPC CIDR only"`

→ **If it breaks:** Revert via Console.

---

### Step 5: Close Default VPC Security Group
→ **Give your agent:** "Remove the 0.0.0.0/0 inbound rules on ports 5432 and 8000 from the default VPC security group (sg-0909201551a067640). Replace with VPC CIDR 172.31.0.0/16. First, list all resources using this security group so we know what could be affected."

→ **Test it:** Monitor CloudWatch for any connection errors across all services for 15 minutes. Check the client portal, Metabase, and any EC2 instances.

→ **If it works:** `git add . && git commit -m "fix: restrict default VPC SG, remove internet exposure"`

→ **If it breaks:** Revert via Console. The default SG may be attached to resources you don't know about.

---

### Step 6: Lock Down Wide-Open Security Groups
→ **Give your agent:** "The Connecteams-VPC-security-group allows ALL protocols from 0.0.0.0/0 and launch-wizard-1 allows ALL traffic from 0.0.0.0/0. First, determine what resources use each SG. If attached to an active EC2 instance, replace with only specific needed ports from VPC CIDR. If nothing uses it, delete the security group."

→ **Test it:** Check if ConnectTeam integrations still function (if still in use). Check any EC2 instances for connectivity.

→ **If it works:** `git add . && git commit -m "fix: lock down Connecteams-VPC and launch-wizard-1 SGs"`

→ **If it breaks:** Revert via Console.

---

### Step 7: Close SSH on All Launch-Wizard Groups
→ **Give your agent:** "For all security groups matching 'launch-wizard-*' (there are 11), remove any SSH (port 22) rules allowing 0.0.0.0/0. If the instance needs remote access, set up AWS SSM Session Manager instead. List all affected instances first."

→ **Test it:** Verify you can still access EC2 instances you actively use via SSM or scoped IP.

→ **If it works:** `git add . && git commit -m "fix: close SSH on all launch-wizard SGs, migrate to SSM"`

→ **If it breaks:** Re-add SSH rule scoped to your specific office IP only.

---

### Step 8: Lock Down n8n (Mo-n8n-firewall)
→ **Give your agent:** "Restrict Mo-n8n-firewall: change port 5678 inbound from 0.0.0.0/0 to your office IP only. Remove SSH 0.0.0.0/0 and replace with SSM access."

→ **Test it:** Access n8n from your network. Confirm workflows still run.

→ **If it works:** `git add . && git commit -m "fix: restrict n8n access to office IP only"`

→ **If it breaks:** Revert via Console.

---

## Danger Zones

- **Step 2 is highest risk** — `connectanalyticsdb` powers the main analytics pipeline and client portal. If any Lambda or Metabase connects from outside the VPC, restricting to VPC CIDR would break it. Test thoroughly before moving on.
- **Step 5 (default VPC SG)** is unpredictable — you don't know everything that uses the default SG. Run the resource check first.
- **Step 6** — if ConnectTeam is still actively used, closing its SG could disrupt workforce scheduling. Verify with Bre/Kristine before modifying.
- **General:** After ALL steps, verify the Daily KPI Email, client portal, Metabase, and Connect analytics pipeline are all functioning. Check again 24 hours later.

**Reminder:** If your agent has been working for more than 5 minutes without showing you results, stop it and check.
