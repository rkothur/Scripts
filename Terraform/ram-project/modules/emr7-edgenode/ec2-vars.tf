resource "aws_instance" "ec2_instance" {
  instance_type          = var.emr7_instance_type
  #name                   = sdh-smdh-dev-EMR-7.0.0-EdgeNode        
  count                  = var.emr7_instance_count
  key_name               = var.emr7_admin_key_name
  monitoring             = true
  vpc_security_group_ids = ["${var.emr7_vpc_security_group}"]
  subnet_id              = var.emr7_subnet_id
  iam_instance_profile   = var.emr7_iam_instance_profile
  ami                    = "${data.aws_ami.proxy_ami.id}"
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 500
    volume_type = "gp3"
  }
  #user_data = file("./user-data.sh")  
  user_data = <<-EOF
  #!/bin/bash
  # Install Latest and required packages
  sudo su
  sleep 10
  echo ""
   echo "CHTR - Install latest updates"
  echo ""
  sudo yum update -y
  sudo yum install wget krb5-workstation openssl openldap mlocate bind-utils nmap rsync ansible dos2unix -y 
  sleep 20
 
  # Install postgres client
  echo ""
  echo "CHTR - Install postgres client"
  echo ""
   sudo yum install postgresql15.x86_64 -y
 
  # Install python 3.11
  echo ""
  echo "CHTR - Install python 3.11"
  echo ""
  sudo yum install python3.11.x86_64 python3.11-pip -y
 
  # Install python modules
  echo ""
  echo "CHTR - Install python modules"
  echo ""
  aws s3 cp s3://${var.prefix}-admin-data/files/requirements.txt /tmp/requirements.txt
  sudo pip3 install -r /tmp/requirements.txt
  rm /tmp/requirements.txt
 
  # Install MySQL client
  echo ""
  echo "CHTR - Install MySQL client"
  echo ""
  sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
  sudo yum install -y https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
  sudo yum install -y mysql-community-client
 
  # Install Microsoft MSSQL client
  echo ""
  echo "CHTR - Install Microsoft MSSQL client"
  echo ""
  curl https://packages.microsoft.com/config/rhel/7.4/prod.repo > /etc/yum.repos.d/msprod.repo
  sudo yum install mssql-tools unixODBC-devel -y
 
  # Install Oracle Client
  echo ""
  echo "CHTR - Install Oracle client"
  echo ""
  sudo wget https://download.oracle.com/otn_software/linux/instantclient/219000/oracle-instantclient-basic-21.9.0.0.0-1.el8.x86_64.rpm
  sudo wget https://download.oracle.com/otn_software/linux/instantclient/219000/oracle-instantclient-sqlplus-21.9.0.0.0-1.el8.x86_64.rpm
  sudo yum localinstall ./oracle-instantclient-basic-21.9.0.0.0-1.el8.x86_64.rpm -y
  sudo yum localinstall ./oracle-instantclient-sqlplus-21.9.0.0.0-1.el8.x86_64.rpm -y
 
  # Install mount-s3
  echo ""
  echo "CHTR - Install mount-s3"
  echo ""
  sudo yum install https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.rpm -y
  sudo yum install ./mount-s3 -y
 
  # Enable GSSAPI authentication for SSH and restart SSH service
  echo ""
  echo "CHTR - Enable GSSAPI authentication"
  echo ""
  sudo sed -i 's/^.*GSSAPIAuthentication.*$/GSSAPIAuthentication yes/' /etc/ssh/sshd_config
  sudo sed -i 's/^.*GSSAPICleanupCredentials.*$/GSSAPICleanupCredentials yes/' /etc/ssh/sshd_config
  sudo systemctl restart sshd
 
  #Below line is required or not?
  sudo chmod 644 /var/aws/emr/userData.json
 
  # Update krb5.conf with DevHadoop and Hadoop entries, set upd prefence limit to force tcp lookups
  echo ""
  echo "CHTR - Update krb5.conf with DevHadoop and Hadoop entries, set reduce upd preference limit"
  echo ""
  sudo cp /etc/krb5.conf /etc/krb5.conf-preadd
  aws s3 cp s3://${var.prefix}-admin-data/files/on-prem-krb.txt /tmp/on-prem-krb.txt
  cat /tmp/on-prem-krb.txt | sudo tee -a /etc/krb5.conf
  sudo sed -i 's/^.*udp_preference_limit = .*$/udp_preference_limit = 1/' /etc/krb5.conf
  sudo rm /tmp/on-prem-krb.txt
  sudo sed -i 's/\r//g' /etc/krb5.conf
 
  # Create Admin User
  echo ""
  echo "CHTR - Create svc-bdadmin User and group"
  echo ""
  sudo groupadd -g 1100 svc-bdadmin
  sudo useradd -u 1100 -g 1100 -s /bin/bash -m -d /home/svc-bdadmin -c "BigData Admin User" svc-bdadmin
 
  # Create App User
  echo ""
  echo "CHTR - Create App User and group"
  echo ""
  sudo groupadd -g 1200 ${var.emr7_app_user_keyname}
  sudo useradd -u 1200 -g 1200 -s /bin/bash -m -d /home/${var.emr7_app_user_keyname} -c "${var.emr7_app_user_keyname} SVC User" ${var.emr7_app_user_keyname}
 
  # Copy keys for app user
  #echo ""
  #echo "CHTR - Create app user and keys"
  #echo ""
  sudo mkdir -p /home/${var.emr7_app_user_keyname}/.ssh
  sudo mkdir -p /home/${var.emr7_app_user_keyname}/.aws
  sudo chmod 700 -R /home/${var.emr7_app_user_keyname}/.aws
  aws s3 cp s3://${var.prefix}-admin-data/scripts/aws-config.sh /bigdata/scripts/aws-config.sh
  sudo sh /bigdata/scripts/aws-config.sh
  sudo chmod 700 -R /home/${var.emr7_app_user_keyname}/.aws/config
  aws s3 cp s3://${var.prefix}-admin-data/certs/${var.emr7_app_user_keyname}.pem /tmp/${var.emr7_app_user_keyname}.pem
  sudo cp /tmp/${var.emr7_app_user_keyname}.pem /home/${var.emr7_app_user_keyname}/${var.emr7_app_user_keyname}.pem
  aws ec2 describe-key-pairs --key-names ${var.emr7_app_user_keyname} --include-public-key --region us-east-1 | jq '.KeyPairs[].PublicKey' |sed 's/\\n//' |sudo tee -a /home/${var.emr7_app_user_keyname}/.ssh/authorized_keys
  sudo chmod 600 /home/${var.emr7_app_user_keyname}/${var.emr7_app_user_keyname}.pem
  sudo chown ${var.emr7_app_user_keyname} /home/${var.emr7_app_user_keyname}/${var.emr7_app_user_keyname}.pem
  sudo chown -R ${var.emr7_app_user_keyname} /home/${var.emr7_app_user_keyname}
  sudo -u ${var.emr7_app_user_keyname} ssh-keygen -y -f /home/${var.emr7_app_user_keyname}/${var.emr7_app_user_keyname}.pem >> /home/${var.emr7_app_user_keyname}/.ssh/authorized_keys
  sudo chmod 600 /home/${var.emr7_app_user_keyname}/.ssh/authorized_keys
  sudo chmod 700 /home/${var.emr7_app_user_keyname}/.ssh/
  sudo chown ${var.emr7_app_user_keyname} /home/${var.emr7_app_user_keyname}/.ssh/authorized_keys
  sudo chown ${var.emr7_app_user_keyname} /home/${var.emr7_app_user_keyname}/.ssh/
  sudo rm /tmp/${var.emr7_app_user_keyname}.pem  
  #Root permissions for admin user
  echo ""
  echo "CHTR - Provide root privileges to admin user"
  echo ""
  echo "svc-bdadmin ALL=(ALL)   NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/bd-admins >/dev/null
  sudo chmod 444 /etc/sudoers.d/bd-admins
 
  # Create /apps for copying other software
  echo ""
  echo "CHTR - Create /apps folder for other apps"
  echo ""
  sudo mkdir /apps
  sudo chmod 755 /apps
  sudo mkdir -p /apps/scripts
  # Install Hadoop Clients
  echo ""
  echo "CHTR - Install Hadoop Clients"
  echo ""
  sudo yum install dos2unix -y
  aws s3 cp s3://${var.prefix}-admin-data/repos/emr7_apps.repo /etc/yum.repos.d/
  aws s3 cp s3://${var.prefix}-admin-data/repos/emr7_platform.repo /etc/yum.repos.d/
  sudo mkdir -p /var/aws/emr/
  aws s3 cp s3://${var.prefix}-admin-data/repos/repoPublicKey.txt /var/aws/emr/repoPublicKey.txt
  dos2unix /etc/yum.repos.d/emr7_platform.repo
  dos2unix /etc/yum.repos.d/emr7_apps.repo  
  sudo groupadd hadoop
  sudo useradd -g hadoop hadoop
  sudo yum install java-17-amazon-corretto-17.0.10+8-1.amzn2023.1.x86_64 -y
  sudo yum install hadoop-client hadoop-lzo spark-core hive hive-hcatalog openssl-devel emrfs emr-* hbase phoenix tez sqoop -y --exclude=emr-amazon-cloudwatch-* --exclude=emr-notebook*
  sudo yum install bc ec2-instance-connect  rsync -y
 
  # Copy Hadoop Configs
  echo ""
  echo "CHTR - Copy Hadoop Configs"
  echo ""
  mkdir -p /mnt/tmp /var/log/hbase /var/log/spark /var/log/hbase /var/log/spark 
  sudo mkdir /mnt/tmp /var/log/hbase /var/log/spark /var/log/hbase /var/log/spark e
  mkdir -p /mnt/s3 /mnt/var/lib/hadoop/tmp /var/log/hive/user /var/log/pig
  chmod 1777 /mnt/tmp /mnt/s3 /mnt/var/lib/hadoop/tmp /var/log/hive/user /var/log/pig
  mkdir -p /usr/share/aws/emr/security/conf/
  mkdir -p /etc/hadoop/conf/ /etc/hive/conf/ /etc/hive-hcatalog/conf/ /etc/tez/conf/ /etc/spark/conf/ /usr/share/aws/emr/security/ /etc/zookeeper/conf /usr/share/aws/emr/emrfs/conf/
  chmod 755 /etc/hadoop/conf/ /etc/hive/conf/ /etc/hive-hcatalog/conf/ /etc/tez/conf/ /etc/spark/conf/ /usr/share/aws/emr/security/ /etc/zookeeper/conf /usr/share/aws/emr/emrfs/conf/
 
  # Get EMR Instance ID
  #Inst_Id=$(aws ec2 describe-instances --filter Name=private-ip-address,Values=${var.emr7_ip} --query 'Reservations[].Instances[].InstanceId' --region us-east-1 --output text)
  # Generate temp key
  sudo rm -rf /tmp/mynew_key*
  ssh-keygen -t rsa -q -N "" -f /tmp/mynew_key
 
  #aws ec2-instance-connect send-ssh-public-key --region us-east-1 --instance-id i-0681532cf524de2d2 --instance-os-user hadoop --ssh-public-key file:///tmp/mynew_key.pub
  aws ec2-instance-connect send-ssh-public-key --region us-east-1 --instance-id $(aws ec2 describe-instances --filter Name=private-ip-address,Values=${var.emr7_ip} --query 'Reservations[].Instances[].InstanceId' --output text) --instance-os-user hadoop --ssh-public-key file:///tmp/mynew_key.pub
  sudo mkdir -p /etc/hudi/conf
  sudo mkdir -p /usr/share/aws/hmclient/lib/
  sudo rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/etc/hadoop/conf/*' /etc/hadoop/conf
  sudo rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/etc/hive/conf/*' /etc/hive/conf
  sudo rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/etc/hive-hcatalog/conf/*' /etc/hive-hcatalog/conf
  sudo rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/etc/tez/conf/*' /etc/tez/conf
  sudo rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/etc/spark/conf/*' /etc/spark/conf
  sudo rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/usr/share/aws/emr/security/*' /usr/share/aws/emr/security/
  sudo rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/usr/share/aws/emr/emrfs/conf/*' /usr/share/aws/emr/emrfs/conf/
  sudo rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/etc/zookeeper/conf/*' /etc/zookeeper/conf
  sudo rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/etc/hudi/conf/hudi-defaults.conf' /etc/hudi/conf/hudi-defaults.conf
  sudo rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/usr/lib/hive/auxlib/aws-glue-datacatalog-hive3-client-3.14.0.jar' /usr/lib/hive/auxlib/aws-glue-datacatalog-hive3-client-3.14.0.jar
  sudo rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/usr/lib/hive/auxlib/aws-glue-datacatalog-spark-client-3.14.0.jar' /usr/lib/hive/auxlib/aws-glue-datacatalog-spark-client-3.14.0.jar
  sudo rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/usr/lib/hive/auxlib/aws-glue-datacatalog-client-common-3.14.0.jar' /usr/lib/hive/auxlib/aws-glue-datacatalog-client-common-3.14.0.jar
  sudo rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/usr/share/aws/iceberg/lib/iceberg*' /usr/lib/spark/jars/
  sudo ln -s /usr/lib/hive/auxlib/aws-glue-datacatalog-hive3-client.jar /usr/lib/hive/auxlib/aws-glue-datacatalog-hive3-client-3.14.0.jar
  sudo ln -s /usr/lib/hive/auxlib/aws-glue-datacatalog-spark-client.jar /usr/lib/hive/auxlib/aws-glue-datacatalog-spark-client-3.14.0.jar
  sudo ln -s /usr/lib/hive/auxlib/aws-glue-datacatalog-client-common.jar /usr/lib/hive/auxlib/aws-glue-datacatalog-client-common-3.14.0.jar
  sudo ln -s /usr/share/aws/hmclient/lib/aws-glue-datacatalog-hive3-client.jar /usr/lib/hive/auxlib/aws-glue-datacatalog-hive3-client.jar
  sudo ln -s /usr/share/aws/hmclient/lib/aws-glue-datacatalog-spark-client.jar /usr/lib/hive/auxlib/aws-glue-datacatalog-spark-client.jar
  sudo ln -s /usr/share/aws/hmclient/lib/aws-glue-datacatalog-client-common.jar /usr/lib/hive/auxlib/aws-glue-datacatalog-client-common.jar
  ssh-keygen -t rsa -q -N "" -f /tmp/mynew_key1
  aws ec2-instance-connect send-ssh-public-key --region us-east-1 --instance-id `aws ec2 describe-instances --filter Name=private-ip-address,Values=${var.emr7_ip} --query 'Reservations[].Instances[].InstanceId' --region us-east-1 --output text` --instance-os-user hadoop --ssh-public-key file:///tmp/mynew_key1.pub
  rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/etc/hbase/conf/*' /etc/hbase/conf
  rsync -avz --delete -e "ssh -i /tmp/mynew_key -o StrictHostKeyChecking=no -o ServerAliveInterval=10" hadoop@"${var.emr7_ip}":'/etc/phoenix/conf/*' /etc/phoenix/conf/
  
  #copy aws-glue jar
  aws s3 cp s3://${var.prefix}-admin-data/files/aws-glue-datacatalog-client-common-3.14.0.jar /usr/share/aws/hmclient/lib/
  aws s3 cp s3://${var.prefix}-admin-data/files/aws-glue-datacatalog-hive3-client-3.14.0.jar /usr/share/aws/hmclient/lib/
  aws s3 cp s3://${var.prefix}-admin-data/files/aws-glue-datacatalog-spark-client-3.14.0.jar /usr/share/aws/hmclient/lib/
  chmod 755 /usr/share/aws/hmclient/lib/*
  aws s3 cp s3://${var.prefix}-admin-data/files/emrfs-hadoop-assembly-2.61.0.jar /usr/lib/spark/jars
  ln -s /usr/share/aws/emr/emrfs/lib/emrfs-hadoop-assembly-2.61.0.jar /usr/lib/spark/jars/emrfs-hadoop-assembly-2.61.0.jar
  cp /usr/share/aws/hmclient/lib/aws-glue-datacatalog-hive3-client-3.14.0.jar /usr/share/aws/hmclient/lib/aws-glue-datacatalog-hive3-client.jar
  cp /usr/share/aws/hmclient/lib/aws-glue-datacatalog-spark-client-3.14.0.jar /usr/share/aws/hmclient/lib/aws-glue-datacatalog-spark-client.jar
  cp /usr/share/aws/hmclient/lib/aws-glue-datacatalog-client-common-3.14.0.jar /usr/share/aws/hmclient/lib/aws-glue-datacatalog-client-common.jar
  ls -ltr /usr/share/aws/hmclient/lib/
  cp -r /usr/share/aws/hmclient/lib/aws-* /usr/lib/hive/auxlib/

  # Install Tidal
  #echo ""
  #echo "CHTR - Install Tidal Agent"
  #echo ""
  #mkdir /opt/TIDAL
  #aws s3 cp s3://${var.prefix}-admin-data/software/tidal.tar.gz /opt/TIDAL
  #cd /opt/TIDAL; tar zxvf tidal.tar.gz
  #mkdir -p /bigdata/scripts
  #aws s3 cp s3://${var.prefix}-admin-data/scripts/chtr-tidal.service /usr/lib/systemd/system/chtr-tidal.service
  #aws s3 cp s3://${var.prefix}-admin-data/scripts/tagent.sh /bigdata/scripts/tagent.sh
  #sed -i 's/agent_template/agent_${var.emr7_tagent_name}/' /bigdata/scripts/tagent.sh
  #chmod +x /bigdata/scripts/tagent.sh
  #systemctl daemon-reload
 
  # systemctl enable chtr-tidal.service
  # systemctl start chtr-tidal.service
  /opt/TIDAL/Agent/bin/tagent agent_${var.emr7_tagent_name} start
  # Audit logins to CloudTrail
  echo ""
  echo "CHTR - Audit logins to CloudTrail"
  echo ""
  aws s3 cp s3://${var.prefix}-admin-data/scripts/check_ec2_ssh.sh /apps/scripts/check_ec2_ssh.sh
  sudo chmod 755 /apps/scripts/check_ec2_ssh.sh
  dos2unix /apps/scripts/check_ec2_ssh.sh
  sudo cp /etc/bashrc /etc/bashrc.orig
  echo -e "# CHTR - Audit to CloudTrail" >> /tmp/bashtmp
  echo -e "export PROMPT_COMMAND='RETRN_VAL=\$?;logger -p local6.debug \"\$SSH_CONNECTION : \$SSH_ORIGIN : \$(whoami) [\$\$]: \$(history 1 | sed \"s/[ ][0–9]+[ ]//\" ) [\$RETRN_VAL]\"'" >> /tmp/bashtmp
  echo -e ". /apps/scripts/check_ec2_ssh.sh" >> /tmp/bashtmp
  cat /tmp/bashtmp |sudo tee -a /etc/bashrc
  sudo rm /tmp/bashtmp
  echo -e "" >> /tmp/syslogtemp
  echo -e "# log commands - CHTR" >> /tmp/syslogtemp
  echo -e "local6.*                                                /var/log/commands.log" >> /tmp/syslogtemp
  sudo yum install rsyslog -y
  sudo systemctl enable rsyslog
  sudo cp /etc/rsyslog.conf /etc/rsyslog.conf.orig
  cat /tmp/syslogtemp | sudo tee -a /etc/rsyslog.conf
  sudo systemctl start rsyslog
  sudo rm /tmp/syslogtemp
  echo -e "/var/log/commands.log {" >> /tmp/logrotatetemp
  echo -e "   missingok" >> /tmp/logrotatetemp
  echo -e "   notifempty" >> /tmp/logrotatetemp
  echo -e "   rotate 4" >> /tmp/logrotatetemp
  echo -e "   weekly" >> /tmp/logrotatetemp
  echo -e "   create" >> /tmp/logrotatetemp
  echo -e "}" >> /tmp/logrotatetemp
  sudo cp /tmp/logrotatetemp /etc/logrotate.d/command
  sudo rm /tmp/logrotatetemp
  aws s3 cp s3://${var.prefix}-admin-data/files/user-commands.json /opt/aws/amazon-cloudwatch-agent/etc/user-commands.json
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/user-commands.json -s
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a stop
  sleep 5
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start
  sudo su hdfs -c "hdfs dfs -mkdir -p /user/ec2-user"
  sudo su hdfs -c "hdfs dfs -chown -R  ec2-user:hdfsadmingroup /user/ec2-user"
  sudo su hdfs -c "hdfs dfs -chown hdfs:hdfs  /user/hadoop"
  sudo su hdfs -c "hdfs dfs -chmod -R 777 /user"
  EOF 
    tags = merge(
      var.tags,
      {
        Name = "${var.prefix}-EMR"
      }
    )
}