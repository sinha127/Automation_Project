#!/bin/bash

# Update the package details and the package list
sudo apt update -y

# Install the apache2 package if it is not already installed
if ! dpkg -s apache2 &> /dev/null; then
sudo apt install -y apache2
fi

# Check if Apache is running
if systemctl --quiet is-active apache2; then
    echo "Apache is running"
else
    # Start Apache
    echo "Starting Apache"
    sudo systemctl start apache2
fi



# Check if Apache service is enabled
if systemctl --quiet is-enabled apache2; then
    echo "Apache service is enabled"
else
    # Enable Apache service
    echo "Enabling Apache service"
    sudo systemctl enable apache2
fi

# Create a tar archive of apache2 access logs and error logs
timestamp=$(date '+%d%m%Y-%H%M%S')
myname="shubham"
tar_name="${myname}-httpd-logs-${timestamp}.tar"
sudo tar czf /tmp/${tar_name} /var/log/apache2/*.log

# Copy the archive to the s3 bucket using the AWS CLI
s3_bucket="upgrad-shubham"
aws s3 cp /tmp/${tar_name} s3://${s3_bucket}/${tar_name}
