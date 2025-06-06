import sys
import subprocess
import json
import requests

cluster_id = 'j-O7WKFTRCIEN2'
cluster_ip = '10.210.56.114'

emr_nodes_list = []
emr_nodes = subprocess.check_output("aws emr list-instances --cluster-id=" + cluster_id, shell = True)
for i in json.loads(emr_nodes)["Instances"]:
   emr_node = {
      "State" : i["Status"]["State"],
      "Ec2InstanceId": i["Ec2InstanceId"],
      "PrivateDnsName": i["PrivateDnsName"]
   }
   emr_nodes_list.append(emr_node)

yarn_nodes = {}
for i in requests.get('http://' + cluster_ip + ':8088/ws/v1/cluster/nodes').json()["nodes"]["node"]:
   yarn_nodes[i["nodeHostName"]] = i["state"]

for i in emr_nodes_list:
   if i["PrivateDnsName"] not in yarn_nodes:
      print (i)