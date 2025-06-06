[p2731345@ncwrnhphbsa0045 cdp717upg]$ cat webui-checks.ksh
#!/bin/ksh

###################
#
# Description: Script to verify the WebUI Ports
#              Make sure to kinit before running the script
#              Update the Webui.txt file before executing the script
#              Output File: /bigdata/scripts/cdp717upg/output/webui-checks-<date:time>.txt
# Written by: Ram
# Date:
#
###################

#### Variables used in the script
#### Note: Do not modify these variabes
PATH=/usr/share/centrifydc/bin/:/bin:/usr/bin:/sbin:/usr/sbin:/opt/VRTS/bin:/usr/sbin/hbanyware
export PATH
NOW=$(date +"%Y%m%d-%H%M")
HST=$(hostname -f)
BOLD=`tput smso`
OFFBOLD=`tput rmso`;
#INFILE="/bigdata/scripts/cdp717upg/ip-webui.txt" --- Use this file if DNS is not resolving the IPs and change hostnames to IPs in the text file
INFILE="/bigdata/scripts/cdp717upg/webui.txt"
OUTDIR="/bigdata/scripts/cdp717upg/output"
OUTFILE="${OUTDIR}/webui-checks-${NOW}.txt"
TAB="\t"
NEWLN="\n"
HEADER="############"


cat $INFILE| while read line
do
   WEB=$(echo $line |awk -F:: '{print $1}')
   LINK=$(echo $line |awk -F:: '{print $2,$3}')
   echo "$HEADER Checking... $WEB $HEADER"| tee -a $OUTFILE
   echo $LINK | tee -a $OUTFILE
   curl -A "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0" -k -Is --negotiate -u : -L "${LINK}" 2>&1 | awk '/HTTP\// {print $2}'| tee -a $OUTFILE
done



[p2731345@ncwrnhphbsa0045 cdp717upg]$ cat webui.txt
CM::https://ncwrnhphbsa0045.hadoop.charter.com:7183/cmf/login
CDP-Infra-1::https://ncwrnhphbsa0045.hadoop.charter.com:8995/
CDP-Infra-2::https://ncwrnhphbsa0046.hadoop.charter.com:8995/
CDP-Infra-3::https://ncwrnhphbsa0047.hadoop.charter.com:8995/
HBASE-Master-1::http://ncwrnhphbsa0045.hadoop.charter.com:16010/master-status
HBASE-Master-2::http://ncwrnhphbsa0046.hadoop.charter.com:16010/master-status
HBASE-Region-1::http://ncwrnhphbsa0047.hadoop.charter.com:16030/rs-status
HBASE-Region-2::http://ncwrnhphbsa0048.hadoop.charter.com:16030/rs-status
HBASE-Region-3::http://ncwrnhphbsa0049.hadoop.charter.com:16030/rs-status
HBASE-Region-4::http://ncwrnhphbsa0050.hadoop.charter.com:16030/rs-status
HDFS-NN-1::https://ncwrnhphbsa0046.hadoop.charter.com:9871/
HDFS-NN-1::https://ncwrnhphbsa0045.hadoop.charter.com:9871/
HDFS-DN-1::https://ncwrnhphbsa0047.hadoop.charter.com:9865/datanode.html
HDFS-DN-2::https://ncwrnhphbsa0048.hadoop.charter.com:9865/datanode.html
HDFS-DN-3::https://ncwrnhphbsa0049.hadoop.charter.com:9865/datanode.html
HDFS-DN-4::https://ncwrnhphbsa0050.hadoop.charter.com:9865/datanode.html
Hive-on-Tez-1::http://ncwrnhphbsa0045.hadoop.charter.com:10011/
Hive-on-Tez-2::http://ncwrnhphbsa0046.hadoop.charter.com:10011/
Impala-state-store::https://ncwrnhphbsa0045.hadoop.charter.com:25010/
Impala-Catalog-server::https://ncwrnhphbsa0046.hadoop.charter.com:25020/
Oozie::http://ncwrnhphbsa0045.hadoop.charter.com:11000/oozie
Ranger::https://ncwrnhphbsa0045.hadoop.charter.com:6182/
Spark::http://ncwrnhphbsa0045.hadoop.charter.com:18088/
Spark2::http://ncwrnhphbsa0045.hadoop.charter.com:18089/
YARN-RM-1::https://ncwrnhphbsa0045.hadoop.charter.com:8090/ui2
YARN-RM-2::https://ncwrnhphbsa0046.hadoop.charter.com:8090/ui2
YARN-History::https://ncwrnhphbsa0045.hadoop.charter.com:19890/
KUDU-Master-1::http://ncwrnhphbsa0050.hadoop.charter.com:8443/
KUDU-Master-2::http://ncwrnhphbsa0046.hadoop.charter.com:8443/
KUDU-Master-3::http://ncwrnhphbsa0047.hadoop.charter.com:8443/
KUDU-Tablet-1::http://ncwrnhphbsa0045.hadoop.charter.com:8050/
KUDU-Tablet-1::http://ncwrnhphbsa0046.hadoop.charter.com:8050/
KUDU-Tablet-1::http://ncwrnhphbsa0047.hadoop.charter.com:8050/
KUDU-Tablet-1::http://ncwrnhphbsa0048.hadoop.charter.com:8050/
KUDU-Tablet-1::http://ncwrnhphbsa0049.hadoop.charter.com:8050/
KUDU-Tablet-1::http://ncwrnhphbsa0050.hadoop.charter.com:8050/
Hue-1::https://ncwrnhphbsa0045.hadoop.charter.com:8888/
Hue-LB::https://ncwrnhphbsa0046.hadoop.charter.com:8889/


[p2731345@ncwrnhphbsa0045 cdp717upg]$ cat ip-webui.txt
CM::https://10.36.10.140:7183/cmf/login
CDP-Infra-1::http://10.36.10.140:8993/
CDP-Infra-1::http://10.36.10.141:8993/
HBASE-Master-1::https://10.36.10.140:16010/master-status
HBASE-Master-2::https://10.36.10.141:16010/master-status
HBASE-Region-1::https://10.36.10.142:16030/rs-status
HBASE-Region-2::https://10.36.10.143:16030/rs-status
HBASE-Region-3::https://10.36.10.144:16030/rs-status
HBASE-Region-4::https://10.36.10.145:16030/rs-status
HDFS-NN-1::https://10.36.10.141:9871/
HDFS-NN-1::https://10.36.10.140:9871/
HDFS-DN-1::https://10.36.10.142:9865/datanode.html
HDFS-DN-2::https://10.36.10.143:9865/datanode.html
HDFS-DN-3::https://10.36.10.144:9865/datanode.html
HDFS-DN-4::https://10.36.10.145:9865/datanode.html
Hive-on-Tez-1::http://10.36.10.140:10011/
Hive-on-Tez-2::http://10.36.10.141:10011/
Hue-LB::https://10.36.10.140:8888/
Hue-1::https://10.36.10.141:8889/
Impala-state-store::https://10.36.10.140:25010/
Impala-Catalog-server::https://10.36.10.141:25020/
Oozie::http://10.36.10.140:11000/oozie
Ranger::https://10.36.10.140:6182/
Spark::http://10.36.10.140:18088/
Spark2::http://10.36.10.140:18089/
YARN-RM-1::https://10.36.10.140:8090/ui2
YARN-RM-2::https://10.36.10.141:8090/ui2
YARN-History::https://10.36.10.140:19890/
[p2731345@ncwrnhphbsa0045 cdp717upg]$
