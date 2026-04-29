# Crimson 2 — EC2 Deployment (Extra Credit 2)

> **Course:** Advanced Cloud Management — Harvard Extension School, Spring 2026  
> **Group:** Crimson 2 · Ghazanfar · Aaron · Chloe  
> **Project:** MedData AWS Migration Dashboard

---

## What this is

This repository contains the **EC2-deployed version** of our capstone dashboard. It is a static single-page app served by **nginx** on a single **Amazon EC2** instance, gated by **Amazon Cognito** authentication.

- **Main capstone repo:** [Link to your main repo here]
- **Live Amplify URL (primary):** [Link to Amplify URL here]
- **Live EC2 URL (this deployment):** `http://YOUR_ELASTIC_IP`

---

## AWS Services Used

| Service | Purpose |
|---------|---------|
| **Amazon EC2** (`t3.micro`) | Compute instance running Amazon Linux 2023 + nginx |
| **Amazon Cognito** | User sign-up, sign-in, password recovery, JWT tokens |
| **AWS Budgets** | Billing alarm (notify at $5 forecasted) |

> **Not used directly:** S3 and CloudFront are not in this stack because nginx serves files locally from the EC2 instance. If traffic scales, migrating to Amplify or S3+CloudFront is recommended.

---

## Estimated Monthly Cost

| Item | Free Tier | On-Demand (no free tier) |
|------|-----------|--------------------------|
| EC2 `t3.micro` | **750 hrs/month free** (12 months) | ~$0.0104/hr ≈ **$7.60/mo** |
| Elastic IP | Free while attached to a running instance | ~$0.005/hr if unattached |
| Data transfer | First 100 GB out free | ~$0.09/GB beyond |
| Cognito MAUs | **First 50,000 free** | ~$0.0055/MAU beyond |

**Total expected cost for coursework:** **$0–8/month** depending on free-tier eligibility and traffic.

> 💡 **Tip:** Set an **AWS Budgets** alarm at $5 to avoid surprises.

---

## Security Assumptions

- **HTTPS:** This demo runs HTTP on port 80. For production, add an SSL certificate (ACM + ALB or use Amplify Hosting which provides HTTPS automatically).
- **No secrets in Git:** Only public Cognito identifiers are committed (`User Pool ID`, `Client ID`, `Region`). No IAM keys, no client secrets.
- **Security Group:** Port 22 (SSH) restricted to your IP; port 80 open to `0.0.0.0/0`; port 443 if you add HTTPS later.
- **Cognito:** Password policy enforced by Cognito; JWT validation handled by the AWS Amplify JS client in the browser.

---

## Shutdown & Budget Limiting

1. **AWS Budgets** → Create a budget with a $5 forecasted alert → email notification.
2. **Stop the EC2 instance** when not demoing (stops compute charges; EBS still bills ~$0.08/GB/mo).
3. **Terminate the instance** and **release the Elastic IP** when the course ends.
4. **Delete the Cognito User Pool** if identities are no longer needed.
5. Review **AWS Cost Explorer** monthly.

---

## Deployment Steps

### 1. Create the Cognito User Pool

1. AWS Console → **Cognito** → **User pools** → **Create user pool**.
2. Provider: **Cognito**.
3. Sign-in option: **Email**.
4. Security requirements: defaults are fine.
5. MFA: **No MFA** (for simplicity).
6. User account recovery: **Email**.
7. Self-service sign-up: **Enabled**.
8. Required attributes: **Email**.
9. Create an **App client**:
   - Name: `ec2-dashboard-client`
   - **Uncheck** "Generate client secret" (SPA flow)
   - Authentication flows: enable **ALLOW_USER_PASSWORD_AUTH** and **ALLOW_USER_SRP_AUTH**
10. After creation, note:
    - `User pool ID` (e.g. `us-east-1_XXXXXXXXX`)
    - `Client ID`
    - `Region`

### 2. Fill in Cognito IDs

Open `index.html` in this repo and replace the placeholders in the `<script type="module">` block at the bottom:

```javascript
const COGNITO_USER_POOL_ID        = 'us-east-1_XXXXXXXXX'; // ← your pool id
const COGNITO_USER_POOL_CLIENT_ID = 'YOUR_CLIENT_ID';      // ← your client id
const COGNITO_REGION              = 'us-east-1';           // ← your region
```

Save, commit, and push to this GitHub repository.

### 3. Launch the EC2 Instance

1. AWS Console → **EC2** → **Launch Instance**.
2. Name: `crimson2-dashboard`
3. AMI: **Amazon Linux 2023**
4. Instance type: **`t3.micro`** (free tier eligible)
5. Key pair: create or select an existing one (you'll need it for SSH)
6. Network settings:
   - Create security group
   - Allow **SSH** from **My IP**
   - Allow **HTTP** from **Anywhere** (`0.0.0.0/0`)
7. **Advanced details** → **User data** → paste the contents of `user-data.sh` from this repo.
8. Launch.

### 4. Assign an Elastic IP

1. EC2 → **Elastic IPs** → **Allocate Elastic IP address**.
2. Select it → **Actions** → **Associate Elastic IP address** → choose your instance.
3. This gives you a stable public IP that survives reboots.

### 5. Update Cognito Callback URLs

1. Cognito → your user pool → **App integration** → **App client** → **Edit**.
2. Under **Hosted UI** or **App client settings**, add your Elastic IP to:
   - Allowed callback URLs: `http://YOUR_ELASTIC_IP`
   - Allowed sign-out URLs: `http://YOUR_ELASTIC_IP`
3. Save.

### 6. Verify

1. Open `http://YOUR_ELASTIC_IP` in a browser.
2. You should see the Cognito sign-in overlay.
3. **Sign up** with a real email → check your inbox for the confirmation code.
4. **Confirm** → **Sign in** → the dashboard should appear.
5. Click **Sign out** and verify you return to the login screen.

---

## Quick Commands (for manual tweaks)

```bash
# SSH into the instance
ssh -i your-key.pem ec2-user@YOUR_ELASTIC_IP

# Check nginx status
sudo systemctl status nginx

# Pull latest dashboard from this repo
cd /usr/share/nginx/html
sudo git pull origin main

# Restart nginx
sudo systemctl restart nginx
```

---

## License / Course Use

This is a coursework artifact for Harvard Extension School. Do not use for production without adding HTTPS, WAF, and proper logging.
