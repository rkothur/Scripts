Note: Replace the <pid> with your PID in the below commands


################################### 
#####  Download the scripts   #####
###################################
Download the scripts from: https://bitbucket.corp.chartercom.com/projects/VDL/repos/adhoc/browse/AWS/EMR/SSO
Files needed: sso-aws.py, sso-aws.bat, show-profiles.bat, requirements.txt 

Example: C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso

############################## 
#####  SSO Script help   #####
##############################

C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso>python sso-aws.py -h
usage: sso-aws.py [-h] [-v V] [-r R] [-s S] [-p P] [-d D] [-k K] [-a A] [-o O]

This script is created to access Panorama Route for Single Sign-on (SSO) and authentication to use aws command line interface.
Note that first run of this script may take more time to do one time setup then later invocation of same script.

options:
  -h, --help  show this help message and exit
  -v V        verbose mode. Default False
  -r R        reset configurations. Default False
  -s S        [os-user]@[vdl-edge-node-tag] SSH to vdl-edge-node-tag as os-user
  -p P        specify aws profile to use for ssh
  -d D        specifies a local “dynamic” application-level port forwarding.
  -k K        specifies to verify or make insecure SSL connection. Default True to verify connection.
  -a A        specifies AWS Region. Default: us-east-1
  -o O        specifies output format. Default: json

############################################### 
#####  Setup Alias to sso script folder   #####
###############################################  

- Command Prompt:
> setx awsdir "C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso"
Note: open new cmd (this is compulsory - setx will not work in same window)
> cd "%awsdir%"

- Gitbash:


- Powershell:
PS C:\Users\p2731345> function awsdir {set-location "C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso" }
PS C:\Users\p2731345> awsdir
PS C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso>


Set vs Setx:
- set modifies the current shell's (the window's) environment values, and the change is available immediately, but it is temporary. The change will not affect other shells that are running, and as soon as you close the shell, the new value is lost until such time as you run set again.
- setx modifies the value permanently, which affects all future shells, but does not modify the environment of the shells already running. You have to exit the shell and reopen it before the change will be available, but the value will remain modified until you change it again.

############################## 
#####  SSO Login to AWS  #####
##############################


Download tesseract: https://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-w64-setup-5.3.3.20231005.exe
Disable netscope on windows machines (Netscope team is working on whitelisting this)

1. Download the aws-sso.zip file to "C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso"
2. Unzip
3. Install python3.11 and AWS CLI from software center
4. open command prompt
5. cd "C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso"
6. python --version (Confirm version is 3.11)
7. pip3 install -r  ./requirements.txt
8. Add to Path - C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso
9. Add to Path - C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\Tools\Terraform
10. python sso-aws.py

C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso>python sso-aws.py -r1
Username(pid): p2731345
SSO URL: https://login.sso.charter.com/nidp/saml2/idpsend?id=pdmi
Do you want to cache configuration(s) for faster access next time [False]: True
Enter path to VIPUIManager: C:\\Program Files (x86)\\Symantec\\VIP Access Client\\VIPUIManager.exe
Enter path to tesseract: C:\\Users\\p2731345\\AppData\\Local\\Programs\\Tesseract-OCR\\tesseract.exe
SSO Password:

Set a Profile Command Prompt:
C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso> SET AWS_PROFILE=spectrum-data-lake-hybrid-cloud

Set a Profile Powershell:
PS C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso> $env:AWS_PROFILE = 'edgecache-uat'
Display: PS C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso > $env:AWS_PROFILE

Test:
C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso> aws s3 ls

############################## 
#####  Show AWS Profiles #####
##############################

C:\Users\p2731345\OneDrive - Charter Communications\Documents\CHTR\AWS\aws-sso> show-profiles.bat
"======"
"Avaialble AWS profiles:"
"======"
smdh-uat
smdh-prod
sdl-prod
sdl-dev

###################################################### 
#####  SSH to edgenode using sso-aws.py script   #####
######################################################

We can login to the EdgeNode using the TagName assigned to the EC2 instance using the below command:
> python sso-aws.py -s ec2-user@sdh-sdl-am-prod-EMR-EdgeNode -p sdl-prod

###################################################### 

#####  Troubleshooting  #####  

###################################################### 

Error: 

requests.exceptions.SSLError: HTTPSConnectionPool(host='signin.aws.amazon.com', port=443): Max retries exceeded with url: /saml (Caused by SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: self-signed certificate in certificate chain (_ssl.c:1006)')))

Try running: > pip install pip-system-certs
