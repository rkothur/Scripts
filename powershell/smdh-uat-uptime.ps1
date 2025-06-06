#################################################
# Description: Powershell script to execute commands on AWS servers
# Author: Ram
# Date: May 2024
#################################################

$ips = "10.210.56.135", "10.210.56.222", "10.210.56.107", "10.210.56.164", "10.210.56.136", "10.210.56.217", "10.210.56.174", "10.210.56.16", "10.210.56.97", "10.210.56.199", "10.210.56.47", "10.210.56.153", "10.210.56.169", "10.210.56.238"

foreach ($ip in $ips){
    write-host "===== $ip====="
    ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-smdh-uat.pem hadoop@$ip "grep udp /etc/krb5.conf"
}