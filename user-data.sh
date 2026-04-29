#!/bin/bash
# Crimson 2 — EC2 bootstrap script for Harvard Cloud Management Extra Credit 2
# This script runs once when the instance launches.

set -e

# 1. Update system packages
yum update -y

# 2. Install nginx and git
yum install -y nginx git

# 3. Enable and start nginx
systemctl enable nginx
systemctl start nginx

# 4. Clear default nginx web root and clone this repo
cd /usr/share/nginx/html
rm -rf ./*

# NOTE: Replace the URL below with YOUR separate GitHub repo URL before launching.
# Example: git clone https://github.com/YOUR_USERNAME/crimson2-ec2-deployment.git .
git clone https://github.com/YOUR_USERNAME/crimson2-ec2-deployment.git .

# 5. Set correct permissions for nginx
chmod -R 755 /usr/share/nginx/html
chown -R nginx:nginx /usr/share/nginx/html

# 6. Restart nginx to pick up new files
systemctl restart nginx

# 7. (Optional) Log completion for debugging
echo "Crimson 2 dashboard deployed at $(date)" > /var/log/crimson2-deploy.log
