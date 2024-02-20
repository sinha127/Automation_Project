#!/bin/bash

# Update package details and package list
sudo apt update -y

# Install apache2 if not already installed
if ! dpkg -l | grep -q apache2; then
    sudo apt install apache2 -y
fi

# Ensure apache2 service is running and enabled
sudo systemctl start apache2
sudo systemctl enable apache2

# Bookkeeping
inventory_file="/var/www/html/inventory.html"
timestamp=$(date +"%m%d%Y%H%M%S")
tar_name="httpd-logs-${timestamp}.tar"

# Check if inventory file exists
if [ ! -f "${inventory_file}" ]; then
    echo -e "Log Type\t\tTime Created\t\tType\t\tSize" > "${inventory_file}"
fi

# Archive logs
sudo tar czf /tmp/${tar_name} /var/log/apache2/*.log

# Copy the archive to the s3 bucket using the AWS CLI
s3_bucket="upgrad-shubham"
aws s3 cp /tmp/${tar_name} s3://${s3_bucket}/${tar_name}

# Bookkeeping
echo -e "httpd-logs\t\t${timestamp}\t\ttar\t\t$(du -sh /tmp/${tar_name} | cut -f1)" >> "${inventory_file}"

# Cron Job
cron_job_file="/etc/cron.d/automation"

# Check if cron job is scheduled
if [ ! -f "${cron_job_file}" ]; then
    echo -e "* * * * * root /root/Automation_Project/automation.sh" > "${cron_job_file}"
fi
