#!/bin/bash

while true
do
   if [ -f "/var/run/yum.pid" ]; 
   then
      sleep 30
   else
      sudo yum update -y
   fi
   if [ -f "/var/run/yum.pid" ];
   then
      sleep 30
   else
      sudo yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
      sudo systemctl enable amazon-ssm-agent
      sudo systemctl start amazon-ssm-agent
      sudo yum install wget krb5-workstation openssl-1 openldap python2.7 mlocate bind-utils nmap amazon-cloudwatch-agent collectd -y
	  sleep 30
	  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:AmazonCloudWatch-linux -s
      exit 0
   fi
   sleep 10
done
