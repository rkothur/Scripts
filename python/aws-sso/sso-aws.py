#!/usr/bin/env python
# Note: Requires Python 3.8 or higher
# This script is created to access Panorama Route for Single Sign-on (SSO) #
# and authentication to use aws command line interface. This script       #
# prompts user for -                                                      #
# SSO URL - This is same URL used to access AWS Console from browser      #
# Other details that user will be prompted includes - PID, PID Password,  #
# VIP Access location, Tesseract location, SSH Location, SCP Location     # 
# etc.                                                                    #
# ----------------------------------------------------------------------- #
# Same script provides following options -                                #
# -h, --help  show this help message and exit                             #
# --debug DEBUG  Prints additional sso request debug information          #
# --reset RESET  Reset cached information.                                #
# --ssh [os-user]@[vdl-edge-node-tag] SSH to vdl-edge-node-tag as os-user #
# --profile PROFILE Specify aws profile to use for ssh                    #
# --d PORT Specifies a local “dynamic” application-level port forwarding. #
# --k K Specifies insecure SSL connections. Default true to verify SSL    # 
# ----------------------------------------------------------------------- #
# Note that AWS Profile Credentials may be valid for longer period of 12  #
# hours. Thus, script won't generate credentials again (, if valid)       #
# But, script ensures to rotate ssh keys every 60 seconds. That said SSH  #
# keys won't be valid for more then 60 seconds and regenerated each time  #
# for security reasons.                                                   #
# This script also ensure dynamic port forwarding to proxy to Resource    #
# Manager, and other Web UI's.                                            #
###########################################################################
import os
import argparse
from argparse import RawTextHelpFormatter
import inquirer
from inquirer.themes import Default
from configparser import ConfigParser
import keyring
import platform
import pathlib
import pytesseract
from os.path import expanduser
import requests
from bs4 import BeautifulSoup
import urllib.parse
import getpass
import subprocess
import time
import pyscreenshot as ImageGrab
from PIL import Image
import pytesseract
import sys
import signal
import re
import xml.etree.ElementTree as ET
import base64
import lxml.etree as etree
import configparser
import boto3
import tempfile
from pathlib import Path
from socket import getaddrinfo, AF_INET, gethostname
import socket
from sshkey_tools.keys import RsaPrivateKey
import json

class Colour:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    
def _print_colour(colour, message, always=False):
    if always or verbose:
        if os.environ.get('CLI_NO_COLOR', False):
            print(message)
        else:
            print(''.join([colour, message, Colour.ENDC]))


def _print_error(message, always=True):
    _print_colour(Colour.FAIL, message, always)
    #sys.exit(1)


def _print_warn(message, always=True):
    _print_colour(Colour.WARNING, message, always)


def _print_msg(message,always=True):
    _print_colour(Colour.OKBLUE, message,always)


def _print_success(message):
    _print_colour(Colour.OKGREEN, message)

#Define argparse bool check
def str2bool(v):
    if isinstance(v, bool):
       return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0', ''):
        return False
    elif v is None:
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

def _read_config(path):
    config = ConfigParser()
    config.read(path)
    return config

def _write_config(config, section, option, value):
    if not config.has_section(section):
        config.add_section(section)
    config.set(section, option, value)
    
def session_get(session,url, payload_headers, ssl_verify):
    # Opens the initial AD FS URL and follows all of the HTTP302 redirects
    response = session.get(url, headers = payload_headers, verify = ssl_verify)
    _print_colour(Colour.UNDERLINE, url)
    _print_colour(Colour.OKGREEN,response.text)
    return response

def session_post(session, url, payload, payload_headers, ssl_verify):
    response = session.post(url, payload, headers = payload_headers, verify = ssl_verify)
    _print_colour(Colour.UNDERLINE, url)
    _print_colour(Colour.OKGREEN,response.text)
    return response

def sso_url_get(session):
    response = session_get(session, url, payload_headers, ssl_verify)
    soup = BeautifulSoup(response.text, features="html.parser")
    return soup

def getSAMLResponse(session, previousSoup):
    newSoup = previousSoup
    
    # Get Post URL
    post_url = newSoup.find('form',{'method': 'POST'}).attrs['action']
    
    # Look for the SAMLResponse assertion
    assertion=''
    for inputtag in newSoup.find_all('input'):
        if (inputtag.get('name') == saml_resp):
            assertion = inputtag.get('value')
    
    credentials = {
        saml_resp: assertion
    }
    
    response = session_post(session, post_url, credentials, payload_headers, ssl_verify)
    newSoup = followJSRedirect(session, BeautifulSoup(response.text, features="html.parser"))
    
    #Find saml account names and number
    for divtag in newSoup.find_all("div", {"class":"saml-account-name"}):
        divtagL = divtag.text.split('(')
        aalias = (divtagL[0].split(':')[1]).strip()
        anmbr = (divtagL[1].split(')')[0]).strip()
        _print_msg(f"Mapping accountnumber {anmbr} with alias name {aalias}", False)
        credentials.update({anmbr: aalias})
    
    if (assertion == ''):
        # TODO: Insert valid error checking/handling
        _print_error('Response did not contain a valid SAML assertion')
        response_file = open('failed_response.html','w')
        response_file.write(newSoup.prettify())
        response_file.close()
        sys.exit(1)
        
    _print_success(f"credentials {credentials}")
    
    return credentials
    
def findToken(attemptCount):
    # Just try once to derive token automatically else prompt for same.
    if attemptCount == 0:
        if vip_path != '':
            pro = subprocess.Popen(vip_path, stdout=subprocess.PIPE)
            time.sleep(3)
            import pyautogui
            vipaccess1 = pyautogui.getWindowsWithTitle(" VIP Access")[0]
            _print_msg("Original Size of VIP Access Window: "+str(vipaccess1.size), False)
            
            x1 = vipaccess1.left
            x2 = vipaccess1.left+vipaccess1.width
            y1 = int(vipaccess1.top+(vipaccess1.height)/2+12)
            y2 = vipaccess1.top+vipaccess1.height
            _print_msg(f"Taking Snap of coordinates - x1: {x1}, y1: {y1}, x2: {x2}, y2: {y2}", False)
            im=ImageGrab.grab(bbox=(x1,y1,x2,y2))
            im.save(image_name)
            img = Image.open(image_name)
            token = pytesseract.image_to_string(img,  lang='eng',config='--psm 6  -c tessedit_char_whitelist=0123456789').strip()
            _print_msg(f"Using Auto-generated token {token}", False)
            
            try:
                os.kill(pro.pid, signal.SIGTERM)
            except:
                _print_warn("Error occured closing VIP Access window.")
                _print_msg("Trying to kill VIP Access window.", False)
                if os_system == 'Windows':
                    vp = pathlib.PureWindowsPath(vip_path)
                    vp = vp.as_posix()
                    vpl = vp.split("/")
                    append_cmd = vpl[-1]
                    if not verbose:
                        append_cmd = append_cmd + ' > NUL 2>&1'
                    os.system("taskkill /f /im " + append_cmd)
            
            if len(token) != 6:
                _print_warn("Could not generate token automatically...")
                token = getpass.getpass(prompt='VIP Token: ')
        else:
            token = getpass.getpass(prompt='VIP Token: ')
    else:
        token = getpass.getpass(prompt='VIP Token: ')
    
    return token

def userTokenLogin(session, previousSoup):
    attemptCount=0
    newSoup = previousSoup
    while newSoup.find('input',{'name':'Ecom_Token'}):
        if (attemptCount> 0):
            _print_warn("Oops, prompted for VIP Token again from ESSO...")
        post_url = newSoup.find('form',{'name': 'IDPLogin'}).attrs['action']
        token = findToken(attemptCount)
        _print_msg('Trying with token '+ token, False)
        
        credentials = {
            "username": pid,
            "token": urllib.parse.quote(token)
        }
        
        response = session_post(session, post_url, 'option=credential&Ecom_User_ID={username}&Ecom_Token={token}'.format(**credentials), payload_headers, ssl_verify)
        del credentials
        newSoup = followJSRedirect(session, BeautifulSoup(response.text, features="html.parser"))
        attemptCount+=1
    return newSoup
        

def userPasswordLogin(session, previousSoup):
    attemptCount=0
    newSoup = previousSoup
    localCache = cache
    global rewriteConfig
    while newSoup.find('input',{'name':'Ecom_Password'}):
        if (attemptCount> 0):
            _print_warn("Oops, prompted for password again from ESSO...")
            if localCache:
                localCache = False
                rewriteConfig = True
            
        post_url = newSoup.find('form',{'name': 'IDPLogin'}).attrs['action']
        global passw
        if localCache:
            passw = getKeyRingPass(script_name, pid)
            if passw is None:
                passw = getpass.getpass(prompt='SSO Password: ')
        else:
            passw = getpass.getpass(prompt='SSO Password: ')
            
        credentials = {
            "username": pid,
            "password": urllib.parse.quote(passw)
        }
        
        response = session_post(session, post_url, 'option=credential&test=null&Ecom_User_ID={username}&Ecom_Password={password}'.format(**credentials), payload_headers, ssl_verify)
        newSoup = followJSRedirect(session, BeautifulSoup(response.text, features="html.parser"))
        del credentials
        attemptCount+=1
    return newSoup

def checkJSRedirect(soup):
    tagcount=0
    scripttag=None
    for tag in soup.find('body').findChildren():
        tagcount+=1
        if (tag.name == "script"):
            scripttag = tag

    if tagcount == 1 and scripttag:
        pattern = re.compile("window.location.href='(.*)'")
        for line in scripttag.string.split("\n"):
            match = pattern.search(line)
            if (match): return match.group(1)

            
def followJSRedirect(session, soup):
    redirectURL = checkJSRedirect(soup)
    if redirectURL:
        response = session_get(session, redirectURL, payload_headers, ssl_verify)
        soup = BeautifulSoup(response.text, features="html.parser")
    return soup

def generateAccessKeys(credentials):
    # Read in the existing config file
    config = configparser.RawConfigParser()
    assertion = credentials[saml_resp]
    sts_assume_role_kwargs = {}
    sts_assume_role_kwargs['SAMLAssertion'] = credentials[saml_resp]
    root = ET.fromstring(base64.b64decode(assertion))
    
    lxml_tree = etree.fromstring(base64.b64decode(assertion))
    _print_msg(str(etree.tostring(lxml_tree, pretty_print=True), "utf-8"),False)
    
    sts_client = boto3.client('sts', verify=ssl_verify)
    
    #Get Session Duration. There is just one.
    for saml2attribute in root.iter('{urn:oasis:names:tc:SAML:2.0:assertion}Attribute'):
        if (saml2attribute.get('Name') == 'https://aws.amazon.com/SAML/Attributes/SessionDuration'):
            for saml2attributevalue in saml2attribute.iter('{urn:oasis:names:tc:SAML:2.0:assertion}AttributeValue'):
                sts_assume_role_kwargs['DurationSeconds'] = int(saml2attributevalue.text)
                _print_msg('DurationSeconds ' + saml2attributevalue.text, False)
            break
    
    #Create config for each profile
    for saml2attribute in root.iter('{urn:oasis:names:tc:SAML:2.0:assertion}Attribute'):
        if (saml2attribute.get('Name') == 'https://aws.amazon.com/SAML/Attributes/Role'):
            for saml2attributevalue in saml2attribute.iter('{urn:oasis:names:tc:SAML:2.0:assertion}AttributeValue'):
                awsrole = saml2attributevalue.text
                account_number = awsrole.split(',')[0][13:25]
                roleName = awsrole.split(',')[0][31:]
                profileName = credentials[account_number]
                _print_msg(f"aws role and arn {awsrole}", False)
                _print_msg(f"Profile {profileName}, role {roleName}, Account {account_number}", False)
                
                sts_assume_role_kwargs['RoleArn'] = awsrole.split(',')[0]
                sts_assume_role_kwargs['PrincipalArn'] = awsrole.split(',')[1]

                try:
                    token = sts_client.assume_role_with_saml(**sts_assume_role_kwargs)
                    
                    _print_msg('STS received token '+str(token), False)
                    
                    if not config.has_section(profileName):
                        config.add_section(profileName)

                    config.set(profileName, output_ltr, outputformat)
                    config.set(profileName, region_ltr, region)
                    config.set(profileName, acc_k_ltr, token['Credentials']['AccessKeyId'])
                    config.set(profileName, sec_k_ltr, token['Credentials']['SecretAccessKey'])
                    config.set(profileName, ses_t_ltr, token['Credentials']['SessionToken'])
                except Exception as e:
                    _print_error(f"Unable to get credentials for {profileName}\n"+str(e))
                finally:
                    sts_client.close()
    
    return config

def generateCredentials(filename):
    # Read in the existing config file
    input_config = _read_config(filename)
    generateNewCred = True
    
    #Check if any one of the defined credentials is valid
    for section in input_config.sections():
        _print_msg('Checking credentials for ' + section, False)
        ak = input_config[section][acc_k_ltr]
        sk = input_config[section][sec_k_ltr]
        st = input_config[section][ses_t_ltr]
        stsC = boto3.client("sts", aws_access_key_id=ak, aws_secret_access_key=sk, aws_session_token=st, verify=ssl_verify)
        try:
            aID = stsC.get_caller_identity()["Account"]
            _print_msg(f"Credentials still valid for {section} ({aID})", False)
            _print_msg(f"Existing credentials still valid", False)
            generateNewCred = False
        except Exception as e:
            _print_warn(f"Unable to get credentials for {section}\n"+str(e))
            _print_msg("Will process to get new credentials. Regenrating...")
        finally:
            stsC.close()
        break
    
    if generateNewCred:
        # Initiate session handler
        session = requests.Session()

        #HTTP Calls
        #1) Get the First Page that redirects to UserName Password Page.
        soup = sso_url_get(session)
        #2) Login into User Password Page and Get security token Page.
        soup = userPasswordLogin(session, soup)
        #3) Get SAML response from security token Page.
        soup = userTokenLogin(session, soup)
        #4) Get dict which contains SAML -> response and account numbers -> account aliases
        credentials = getSAMLResponse(session, soup) 

        #Get config with access key and Secrets for each account
        accesskeysconfig = generateAccessKeys(credentials)

        # Write the updated config file
        with open(filename, 'w+') as configfile:
            accesskeysconfig.write(configfile)
    
    return generateNewCred

def _select_profile(filename):
    config = _read_config(filename)

    profiles = []
    for section in config.sections():
        profiles.append(re.sub(r"^profile ", "", str(section)))
    profiles.sort()

    questions = [
        inquirer.List(
            'name',
            message='Please select an AWS config profile',
            choices=profiles
        ),
    ]
    answer = inquirer.prompt(questions, theme=Default())
    return answer['name'] if answer else sys.exit(1)

def makeTempDir():
    tmp = tempfile.gettempdir()
    tmpPath = tempDir
    if tmp is not None:
        tmpPath = tmp +'/'+ tmpPath
    _print_msg(f"Create Temporary Folder for saving files with name {tmpPath}", False)
    os.makedirs(tmpPath, exist_ok=True)
    return tmpPath

def getAllIPAddr():
    resp = set()
    for ip in getaddrinfo(host=gethostname(), port=None, family=AF_INET):
        resp.add(ip[4][0])
    
    return resp
    
def generateRSAKeyPair(privateKey, publicKey, comment):
    rsa_priv = RsaPrivateKey.generate()
    rsa_priv.public_key.comment = comment       
    rsa_priv.to_file(privateKey)
    rsa_priv.public_key.to_file(publicKey)
    #change file permissions
    os.chmod(privateKey, 0o600)
    os.chmod(publicKey, 0o600)   

def ec2DescribeInstances(ak, sk, st, sshENTag):
    ec2Client = boto3.client("ec2", aws_access_key_id=ak, aws_secret_access_key=sk, aws_session_token=st, region_name=region, verify=ssl_verify)
    response = {}
    try:
        response = ec2Client.describe_instances(Filters=[
                    {
                        'Name': 'tag:Name',
                        'Values': [
                                    sshENTag,
                                  ]
                    }
                    ])
    finally:
        ec2Client.close()

    return response

def sendSSHKeyToEc2(pubKey,ak,sk,st,enAZ,enInstanceID,sshUser):
    ec2InstanceConnClient = boto3.client("ec2-instance-connect", aws_access_key_id=ak, aws_secret_access_key=sk, aws_session_token=st, region_name=region, verify=ssl_verify)
    responseSendKey = {}    
    # Read Public Key
    with open(pubKey, 'r') as file:
        pubKeydata = file.read().rstrip()
    try:
        responseSendKey = ec2InstanceConnClient.send_ssh_public_key(
                AvailabilityZone = enAZ,
                InstanceId = enInstanceID,
                InstanceOSUser = sshUser,
                SSHPublicKey = pubKeydata,
            )
    finally:
        ec2InstanceConnClient.close()
    
    return responseSendKey



def doSSH(filename):
# Do the SSH
    if ssh is not None:
        sshList = ssh.split("@")
        sshUser = sshList[0]
        sshENTag = sshList[1] 
        dPort = 0
        sshProfile = profile
        
        if dynamic_forwarding_port is not None:
            dPort = int(dynamic_forwarding_port)
        
        if sshProfile is None:
            sshProfile = _select_profile(filename)    
        
        _print_msg(f"ssh user {sshUser}, EC2 {sshENTag} using aws profile {sshProfile}"
        , False)
        _print_msg(f'Dynamic port for TCP forwarding ({dPort})', False)
        
        #Make Temp Directory
        tmpPath = makeTempDir()     
        
        ipsList = getAllIPAddr()
        ipsStr = ':'.join(ipsList)
        currentUser = getpass.getuser()
        hostName = socket.gethostname()
        domainName = ''
        userdomain = ''
        if os_system == 'Windows':
            domainName = '.'+os.getenv('USERDNSDOMAIN')
            userdomain = os.getenv('USERDOMAIN') + "\\"
        
        #Generate Public Private RSA Key
        # Generate RSA (default is 4096 bits)
        pkey = pathlib.PureWindowsPath(tmpPath+'/ssop').as_posix()
        pubKey = pathlib.PureWindowsPath(tmpPath+'/ssop.pub').as_posix()
        comment = f"{userdomain}{currentUser}@{hostName}{domainName}"
        generateRSAKeyPair(pkey, pubKey, comment)
        
        #get Boto3 ec2 Client for profile to get instance name and Ip from tag name 
        input_config = _read_config(filename)
        ak = input_config[sshProfile][acc_k_ltr]
        sk = input_config[sshProfile][sec_k_ltr]
        st = input_config[sshProfile][ses_t_ltr]
        
        response = ec2DescribeInstances(ak,sk,st,sshENTag)
        
        _print_msg(f'Response from describe instances- ({response})', False)
        #pJsonResp = json.loads(response)
        enInstanceID = response["Reservations"][0]["Instances"][0]["InstanceId"]
        enIPAddress = response["Reservations"][0]["Instances"][0]["PrivateIpAddress"]
        enAZ = response["Reservations"][0]["Instances"][0]["Placement"]["AvailabilityZone"]
        
        responseSendKey = sendSSHKeyToEc2(pubKey,ak,sk,st,enAZ,enInstanceID,sshUser)
        
        _print_msg(f"Response from send_ssh_public_key ({responseSendKey})",False)
        
        # get request ID
        requestIDStr = responseSendKey['RequestId']    
        
        ssh_origin = f"{currentUser}@{hostName}{domainName}[{ipsStr}][{requestIDStr}]"
        
        _print_msg(f'Writing data to IP File ({ssh_origin})', False)
        
        # Write files to Temp Folder
        for ip in ipsList:
            fN = tmpPath+'/'+ ip
            f = open( fN, 'w' )
            f.write(ssh_origin)
            f.close()
        
        if os_system == 'Windows':
            subprocess.call(["scp", "-i", pkey, f"{tmpPath}/*.*.*", f"{sshUser}@{enIPAddress}:/tmp/"])
        else:
            subprocess.Popen(f"scp -i {pkey} {tmpPath}/*.*.* {sshUser}@{enIPAddress}:/tmp/", shell=True)
        
        if dPort == 0:
            subprocess.call(["ssh", "-i", pkey, f"{sshUser}@{enIPAddress}"])
        else:
            subprocess.call(["ssh", "-D", f"{dPort}", "-i", pkey, f"{sshUser}@{enIPAddress}"])    

def getKeyRingPass(script_name,pid):
    if os_system == 'Windows':
        return keyring.get_password(script_name, pid)
    else:
        return None

def deleteKeyRingPass(script_name,pid):
    if os_system == 'Windows':
        keyring.delete_password(script_name, pid)

def setKeyRingPass(script_name,pid,passw):
    if os_system == 'Windows':
        keyring.set_password(script_name, pid, passw)
    
#Add options for help
parser = argparse.ArgumentParser(description="This script is created to access Panorama Route for Single Sign-on (SSO) and authentication to use aws command line interface.\nNote that first run of this script may take more time to do one time setup then later invocation of same script.",formatter_class=RawTextHelpFormatter
)
parser.add_argument('-v', type=str2bool, default=False, help='verbose mode. Default False')
parser.add_argument('-r', type=str2bool, default=False, help='reset configurations. Default False')
parser.add_argument('-s', help='[os-user]@[vdl-edge-node-tag] SSH to vdl-edge-node-tag as os-user')
parser.add_argument('-p', help='specify aws profile to use for ssh')
parser.add_argument('-d', help='specifies a local “dynamic” application-level port forwarding.')
parser.add_argument('-k', type=str2bool, default=True, help='specifies to verify or make insecure SSL connection. Default True to verify connection.')
parser.add_argument('-a', default='us-east-1', help='specifies AWS Region. Default: us-east-1')
parser.add_argument('-o', default='json', help='specifies output format. Default: json')
args = parser.parse_args()

#Set variables
verbose = args.v
reset = args.r
ssh = args.s
profile = args.p
dynamic_forwarding_port = args.d
ssl_verify = args.k
region = args.a
outputformat = args.o
config_file_name='sso-aws.config'
pid_ltr='pid'
sso_ltr='sso'
url_ltr='url'
cache_ltr='cache'
show_cachemsg_ltr='show'
vip_ltr='vip'
tesseract_ltr='tesseract'
script_name='sso-aws.py'
os_system = platform.system()
awsconfigfile = '/.aws/credentials' 
payload_headers= {'Content-Type': 'application/x-www-form-urlencoded'}
passw = ''
image_name = 'ssovipaccessst.png'
saml_resp = 'SAMLResponse'
output_ltr = 'output'
region_ltr = 'region'
acc_k_ltr = 'aws_access_key_id'
sec_k_ltr = 'aws_secret_access_key'
ses_t_ltr = 'aws_session_token'
# Set aws credential location as home folder
home = expanduser("~")
filename = home + awsconfigfile
tempDir = 'ssoemrsshec2'

_print_msg('Verbose mode is set to '+ str(verbose), False)
_print_msg('Reset Flag is set to ' + str(reset), False)
_print_msg('SSH '+ str(ssh), False)
_print_msg('Using profile ' + str(profile), False)
_print_msg('Port for dynamic forwarding '+ str(dynamic_forwarding_port), False)
_print_msg('SSL verify '+ str(ssl_verify), False)
_print_msg('AWS region '+ str(region), False)
_print_msg('Output format '+ str(outputformat), False)
_print_msg('Reading configurations from '+ config_file_name, False)
_print_msg('AWS Credentials would be saved in '+ filename, False)

config = _read_config(config_file_name)

pid = ''
# Check for PID
if config.has_option(sso_ltr, pid_ltr):
    pid = config[sso_ltr][pid_ltr]

# if reset flag is set then clean config file, windows credentials and AWS credentials
if reset:
    open(config_file_name, 'w').close()
    open(filename, 'w').close()
    cached_pass = getKeyRingPass(script_name, pid)
    if cached_pass is not None:
        deleteKeyRingPass(script_name, pid)
    pid = ''
    config = _read_config(config_file_name)
    if verbose:
        _print_success('Reset done')
 
if pid == "" :
    pid = input('Username(pid): ')
    
# Check for SSO URL
if config.has_option(sso_ltr, url_ltr):
    url = config[sso_ltr][url_ltr]
else:
    url = input('SSO URL: ')
    _write_config(config, sso_ltr, url_ltr, url)

cache = False
rewriteConfig = True
# Check for caching the configuration
if config.has_option(sso_ltr, cache_ltr):
    cache = str2bool(config[sso_ltr][cache_ltr])
    rewriteConfig = False
else:
    cache = str2bool(input('Do you want to cache configuration(s) for faster access next time [False]: '))

#Check for path to VIP Access
if config.has_option(sso_ltr, vip_ltr):
    vip_path = config[sso_ltr][vip_ltr]
else:
    vip_path = input('Enter path to VIPUIManager: ')
    
#Check for path of Tesseract
if config.has_option(sso_ltr, tesseract_ltr):
    tesseract_path = config[sso_ltr][tesseract_ltr]
else:
    tesseract_path = input('Enter path to tesseract: ')

if tesseract_path != '':
    t_p = tesseract_path
    #backslashes (\) for Windows and forward slashes (/) for Linux
    if os_system == 'Windows':
        p = pathlib.PureWindowsPath(tesseract_path)
        t_p = p.as_posix()
    pytesseract.pytesseract.tesseract_cmd = t_p

# generate AWS Credentials
new_cred_gen = generateCredentials(filename)
_print_msg('New Credentials generated '+ str(new_cred_gen), False)

# Write Data to Cache after credential generation
if cache:
   _write_config(config, sso_ltr, pid_ltr, pid)
   _write_config(config, sso_ltr, cache_ltr, str(cache))
   _write_config(config, sso_ltr, vip_ltr, vip_path)
   _write_config(config, sso_ltr, tesseract_ltr, tesseract_path)
   if rewriteConfig:
    setKeyRingPass(script_name, pid, passw)
    # save to a file
    with open(config_file_name, 'w') as configfile:
        config.write(configfile)

#SSH
doSSH(filename)