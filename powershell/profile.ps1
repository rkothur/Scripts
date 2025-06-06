# Description: Create aliases for ssh and other frequently used commands in powershell
#              Create profile.ps1 file and add below entries
#              Change path to pem file, IPs and Description
#              Execute in powershell PS C:\Users\p2731345> . .\profile.ps1
# Author: Ram Kothur
# Date: Mar 2024

########## SFPP - UAT ##########
# SFPP UAT EdgeNode 
function ssh-sfpp-uat-edge { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-smdh-uat.pem ec2-user@10.210.56.57}

# SFPP UAT MasterNode1
function ssh-sfpp-uat-master1 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-smdh-uat.pem hadoop@10.210.56.34}

# SFPP UAT MasterNode2 
function ssh-sfpp-uat-master2 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-smdh-uat.pem hadoop@10.210.56.166}

# SFPP UAT MasterNode3
function ssh-sfpp-uat-master3 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-smdh-uat.pem hadoop@10.210.56.25}

########## SFPP - Prod ##########
# SFPP Prod EdgeNode 
function ssh-sfpp-prod-edge { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-smdh-prod.pem ec2-user@10.210.60.235}

# SFPP Prod MasterNode1
function ssh-sfpp-prod-master1 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-smdh-prod.pem hadoop@10.210.60.179}

# SFPP Prod MasterNode2 
function ssh-sfpp-prod-master2 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-smdh-prod.pem hadoop@10.210.60.28}

# SFPP Prod MasterNode3
function ssh-sfpp-prod-master3 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-smdh-prod.pem hadoop@10.210.60.155}


########## EC - QA ##########
# EC QA EdgeNode
function ssh-ec-qa-edge { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-ec-qa.pem ec2-user@10.210.43.221}

# EC QA Master
function ssh-ec-qa-master { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-ec-qa.pem hadoop@10.210.43.137}

########## EC - UAT ##########
# EC UAT EdgeNode emr6
function ssh-ec-uat-edge-emr6 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-ec-uat.pem ec2-user@10.210.49.52}

# EC UAT Master emr6
function ssh-ec-uat-master-emr6 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-ec-uat.pem hadoop@10.210.49.51}

# EC UAT HMaster emr6
function ssh-ec-uat-hmaster-emr6 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-ec-uat.pem hadoop@10.210.49.107}

########## EC - Prod ##########
# EC Prod EdgeNode
function ssh-ec-prod-edge-emr6 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-ec-prod.pem ec2-user@10.210.50.11}

# EC Prod Master emr6
function ssh-ec-prod-master-emr6 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-ec-prod.pem hadoop@10.210.50.22}

# EC Prod HMaster emr6
function ssh-ec-prod-hmaster-emr6 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-ec-prod.pem hadoop@10.210.50.184}

########## SDL AM - Dev ##########

# SDL Dev AM EdgeNode 
function ssh-am-dev-edge { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-dev.pem ec2-user@10.210.23.36}

# SDL Dev AM Master1 
function ssh-am-dev-master1 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-dev.pem hadoop@10.210.23.39}

# SDL Dev AM Master2 
function ssh-am-dev-master2 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-dev.pem hadoop@10.210.23.40}

# SDL Dev AM Master3 
function ssh-am-dev-master3 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-dev.pem hadoop@10.210.23.62}

# SDL Dev AM HBase Master1 
#function ssh-am-dev-hbase-master1 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-dev.pem hadoop@10.210.17.116}

# SDL Dev AM HBase Master2 
#function ssh-am-dev-hbase-master2 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-dev.pem hadoop@10.210.17.116}

# SDL Dev AM HBase Master3 
#function ssh-am-dev-hbase-master3 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-dev.pem hadoop@10.210.17.116}

########## SDL AM - Prod ##########
# SDL Prod AM EdgeNode1
function ssh-am-prod-edge1 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-prod.pem ec2-user@10.210.17.62}

# SDL Prod AM EdgeNode2
function ssh-am-prod-edge2 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-prod.pem ec2-user@10.210.17.61}

# SDL Prod AM Master1 
function ssh-am-prod-master1 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-prod.pem hadoop@10.210.17.116}

# SDL Prod AM Master2 
function ssh-am-prod-master2 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-prod.pem hadoop@10.210.17.102}

# SDL Prod AM Master3 
function ssh-am-prod-master3 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-prod.pem hadoop@10.210.17.105}

# SDL Prod AM HBase Master1 
function ssh-am-prod-hbase-master1 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-prod.pem hadoop@10.210.17.122}

# SDL Prod AM HBase Master2 
function ssh-am-prod-hbase-master2 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-prod.pem hadoop@10.210.17.124}

# SDL Prod AM HBase Master3 
function ssh-am-prod-hbase-master3 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-prod.pem hadoop@10.210.17.120}

########## SDL CX - Dev ##########
# SDL Dev CX EdgeNode 
function ssh-cx-dev-edge { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-dev.pem ec2-user@10.210.23.109}

# SDL Dev CX Master1 
function ssh-cx-dev-master1 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-dev.pem hadoop@10.210.23.115}

# SDL Dev CX Master2 
function ssh-cx-dev-master1 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-dev.pem hadoop@10.210.23.114}

# SDL Dev CX Master3 
function ssh-cx-dev-master1 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-dev.pem hadoop@10.210.23.100}

########## SDL CX - UAT ##########
# SDL UAT CX EdgeNode 
function ssh-cx-uat-edge { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-uat.pem ec2-user@10.210.64.87}

# SDL UAT CX Master1 
function ssh-cx-uat-master1 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-uat.pem hadoop@10.210.64.11}

# SDL UAT CX Master2 
function ssh-cx-uat-master2 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-uat.pem hadoop@10.210.64.57}

# SDL UAT CX Master3 
function ssh-cx-uat-master3 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-am-uat.pem hadoop@10.210.64.30}


########## SDL CX - Prod ##########
# SDL Prod CX EdgeNode1

# SDL Prod CX EdgeNode2

# SDL Prod CX Master1 

# SDL Prod CX Master2 

# SDL Prod CX Master3 

########## SMDH - Dev ##########
# SMDH Dev EdgeNode
function ssh-smdh-dev-edge { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-smdhmob-dev.pem ec2-user@10.210.100.230}

# SMDH Dev Master1
function ssh-smdh-dev-master1 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-smdhmob-dev.pem hadoop@10.210.100.33}

# SMDH Dev Master2
function ssh-smdh-dev-master2 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-smdhmob-dev.pem hadoop@10.210.100.82}

# SMDH Dev Master3
function ssh-smdh-dev-master3 { ssh -D8157 -i C:\Users\p2731345\aws-keys\svc-bdadmin-smdhmob-dev.pem hadoop@10.210.100.125}


########## SMDH - UAT ##########

########## SMDH - Prod ##########

########## SMDH Dataone - Dev ##########

########## SMDH Dataone - UAT ##########

########## SMDH Dataone - Prod ##########


# cd to sso folder 
function awsdir {set-location "C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso" }

# cd to aws keys folder 
function awskeys {set-location "C:\Users\p2731345\aws-keys" }

# cd to home folder 
function homedir {set-location "C:\Users\p2731345" }

# cd to terraform folder
function terradir {set-location "C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\Tools\Terraform"}

# login to aws sso
function aws-login { cd "C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso"; python.exe ./sso-aws.py }

# show aws profiles
#function showprofiles {powershell -Command "(gc %HOMEPATH%\.aws\credentials |findstr [) -replace '\[', '' -replace '\]', ''"}
function show-profiles {powershell -Command "(gc .\.aws\credentials |findstr [) -replace '\[', '' -replace '\]', ''"}

# Open notepad++
# You can open a file with the command line option after executing the profile ex: > opennpp C:\Users\p2731345\profile.ps1
function opennpp {
	param(
	[string]$a 
	)
	
	if ($a) {
	    Start-Process -FilePath "C:\Program Files\Notepad++\notepad++" $a 
	} else {
		Start-Process -FilePath "C:\Program Files\Notepad++\notepad++"
	}
}

# Open git bash
function opengitbash { Start-Process -FilePath "C:\Program Files\Git\git-bash.exe" }

# List all ssh functions available
echo ""
echo "Available Connections"
echo "====================="
echo ""
#get-childitem function:| select-string ssh | sort | write-host -Separator " , " -NoNewline
get-childitem function:| select-string ssh | sort

# List all dir functions available
echo ""
echo "Available dir shortcuts"
echo "====================="
echo ""
#get-childitem function:| select-string dir | sort | write-host -Separator " , " -NoNewline
get-childitem function:| select-string dir | sort 

# List all open functions available
echo ""
echo "Available open shortcuts"
echo "====================="
echo ""
#get-childitem function:| select-string dir | sort | write-host -Separator " , " -NoNewline
get-childitem function:| select-string open | sort 