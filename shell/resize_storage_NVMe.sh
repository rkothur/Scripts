#!/bin/bash

# This BA scales up the EBS storage on the cluster nodes if the usage exceeds 90% of total capacity
#
# Usage:
# --scaling-factor - percentage by which to increase the size when usage exceeds 90%

# Author: Jigar Mistry jimistry@amazon.com
# Modified by: Chris Goetz goetzc@amazon.com (Added support for LUKS encrypted volumes)
# Modified by: Marco Vitucci mvvitucc@amazon.com (Added support for NVMe block devices)

# Last updated: 25/05/2022

#set -x
set -e

if [[ $# -eq 2 && $1 == "--scaling-factor" && $2 =~ [1-9] ]]; then
        scalingFactor=$2
else
        echo "Failed to run the script!"
        echo "Usage: resize_storage.sh --scaling-factor <percentage by which to increase the size when usage exceeds 90%>"
        exit 1
fi

if [ -f "/tmp/resize_storage_script.sh" ]; then
        echo "File /tmp/resize_storage_script.sh already exists!"
        echo "ERROR: This script has already been installed on this system. Please remove the script in /tmp to reconfigure."
        exit 1
fi

blockDeviceMapping=$(/usr/bin/curl http://169.254.169.254/latest/meta-data/block-device-mapping/ | xargs)
if [[ $blockDeviceMapping =~ ebs ]]; then
        echo "INFO: EBS volume(s) detected on this node"
else
        echo "ERROR: This node has no EBS volumes attached to it! Only EBS volumes can be resized...failing the script."
        exit 1
fi

is_master=$(cat /emr/instance-controller/lib/info/instance.json | jq .isMaster)

if [ $is_master != "true" ]; then
        is_master="false"
fi

RESIZE_STORAGE_SCRIPT=$(cat <<EOF1

echo \$(date)

while [ "\$(sed '/localInstance {/{:1; /}/!{N; b1}; /nodeProvision/p}; d' /emr/instance-controller/lib/info/job-flow-state.txt | sed '/nodeProvisionCheckinRecord {/{:1; /}/!{N; b1}; /status/p}; d' | awk '/SUCCESSFUL/' | xargs)" != "status: SUCCESSFUL" ];
do
  sleep 1
done

currentCronJobs=\$(crontab -l 2>/dev/null || :)

if [[ "\$currentCronJobs" != *"resize_storage"* ]]; then
    (crontab -l 2>/dev/null || :; echo "*/2 * * * * /tmp/resize_storage_script.sh >> /tmp/resize_storage.log 2>&1") | crontab -
fi

yarnDirs=\$(xmllint --xpath "//configuration/property[name='yarn.nodemanager.local-dirs']/value/text()" /etc/hadoop/conf/yarn-site.xml)

mntString=\$(echo \$yarnDirs | grep -o "mnt[0-9]*" | xargs) #Extracting the mount points
mntString=\$(echo "\${mntString//' '/|}")

az=\$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
region=\$(echo \$az | sed 's/[a-z]\$//')

if [ $is_master == "true" ]; then
        mntString=\$mntString"|xvda1|nvme0"
fi

#Looping through output of "df -h" and checking usage
df -h | grep -E "(\$mntString)" | awk '{ print \$5 " " \$1 " " \$6 " " \$2}' | while read line;
do
    disk=\$(echo \$line | awk '{print \$2}')
    mountPoint=\$(echo \$line | awk '{print \$3}')
    diskUsage=\$(echo \$line | awk '{print \$1}' | cut -d'%' -f1)
    diskSize=\$(echo \$line | awk '{print \$4}' | cut -d'G' -f1)
    if [ \$diskUsage -ge 90 ]; then
        echo "Attempting to resize volume \$disk..."
        
        isnvme=false
        #Renaming the disk name since EC2 renames the disk when initially attached
        if [[ \$disk == *"nvme"* ]]; then
            isnvme=true
            diskCheck=\$(lsblk -no pkname \${disk})
            
            if [[ \$diskCheck == "" ]]; then
                renamedDisk=\${disk} 
                isPartition=false
            else
                renamedDisk=/dev/\${diskCheck##*/}
                isPartition=true
            fi
        elif [[ \$disk == "/dev/xvda1" ]]; then
            renamedDisk="/dev/xvda"
            searchDisk="/dev/xvda"
        elif [[ \$disk =~ "mapper" ]]; then
            renamedDisk=\${disk/xv/s}
            renamedDisk=\${renamedDisk/[1-9]/}
            searchDisk=\${renamedDisk/mapper\//}
        else
            renamedDisk=\${disk/xv/s}
            renamedDisk=\${renamedDisk/[1-9]/}
            searchDisk=\$renamedDisk
        fi

        if \$isnvme; then
            volumeId=\$(sudo /sbin/ebsnvme-id \$renamedDisk -v | sed 's/Volume ID: //') 
        else
            instanceId=\$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id)
            blockDeviceMapping=\$(aws ec2 describe-instances --region \$region --instance-ids \$instanceId | jq .Reservations[].Instances[].BlockDeviceMappings)
            volumeId=\$(echo \$blockDeviceMapping | jq '.[] | select(.DeviceName=='"\"\$searchDisk\""') | .Ebs.VolumeId')
            volumeId=\${volumeId//\"/}
        fi

        if [[ \$volumeId = "" ]]; then
            echo "WARN: Not able to find the EBS volume ID for \$disk as it might be an instance store volume. Only EBS volumes can be resized."
            continue
        fi
        
        #Resizing the volume
        targetCapacity=\$(echo "scale=2;$scalingFactor/100*\$diskSize" | bc -l)
        targetCapacity=\$(echo \$targetCapacity+\$diskSize | bc -l | awk '{print int(\$1)}')
        aws ec2 modify-volume --region \$region --volume-id \$volumeId --size \$targetCapacity
        volumeStatus=""
        while [[ \$volumeStatus != "optimizing" && \$volumeStatus != "completed" ]]
        do
            sleep 5
            volumeStatus=\$(aws ec2 describe-volumes-modifications --region \$region --volume-id \$volumeId | jq .VolumesModifications[].ModificationState)
            volumeStatus=\${volumeStatus//\"/}
        done


        echo "Expanding the partition..."
        if \$isnvme; then
            if \$isPartition; then
                partitionNumber=\${disk: -1}
                sudo growpart \${renamedDisk/mapper\//} \$partitionNumber
            else
                echo "No partitioning. Skipping growpart..."
            fi
        else
            partition=\${disk/[1-9]*/}
            partitionNumber=\${disk/\/dev\/xv[a-z][a-z]/}
            partitionNumber=\${partitionNumber/\/dev\/mapper\/xv[a-z][a-z]/}
            if [[ -z "\${partitionNumber// }" ]]; then
                echo "No partitioning. Skipping growpart..."
            else
                sudo growpart \${partition/mapper\//} \$partitionNumber
            fi
        fi

        echo "Resizing the filesystem..."
        fileSystemTypes="ext4|XFS"
        
        #check for dm- encrypted EMR device.
        isLUKS=\$(sudo ls -la \$disk | awk '{print \$11}')
        if [[ \$isLUKS =~ "dm-" ]]; then
            isLUKS=\${isLUKS/\.\.//}
            isLUKS=/dev/\$isLUKS
            echo "Volume is LUKS Encrypted: resizing LUKS."
            sudo cryptsetup resize \$disk
        else
            isLUKS=\$disk
        fi
        
        detectedFileSystem=\$(sudo file -s \$isLUKS | grep -oE "(\$fileSystemTypes)")

        if [ \$detectedFileSystem == "XFS" ]; then
            sudo xfs_growfs -d \$mountPoint
        else
            sudo resize2fs \$disk
        fi
    else
        echo "Resize not needed for \$disk"
    fi
done
exit 0

EOF1
)

echo "${RESIZE_STORAGE_SCRIPT}" | tee -a /tmp/resize_storage_script.sh
chmod u+x /tmp/resize_storage_script.sh
/tmp/resize_storage_script.sh > /tmp/resize_storage_script.log 2>&1 &

exit 0