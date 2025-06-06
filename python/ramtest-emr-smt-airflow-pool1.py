"""
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""
from airflow import DAG
 
from airflow.providers.amazon.aws.operators.emr import EmrCreateJobFlowOperator
from airflow.providers.amazon.aws.operators.emr import EmrAddStepsOperator
from airflow.providers.amazon.aws.operators.emr import EmrTerminateJobFlowOperator
from airflow.operators.python_operator import PythonOperator, BranchPythonOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.providers.amazon.aws.sensors.emr import EmrStepSensor

from airflow.utils.dates import days_ago
from datetime import timedelta
import os

# Variables
PREFIX='ramtest'
APP_USER_KEYNAME='svc-bdadmin-smdh-dev'
LOGS_BUCKET_NAME='ramtest-aws-logs'
YARN_LOG_PATH=PREFIX + '-yarn-logs'
SPARK_LOG_PATH=PREFIX + '-spark-logs'
SCRIPTS_BUCKET='ramtest-admin-data'
SCRIPTS_PATH='transient/scripts' 
DAG_ID = os.path.basename(__file__).replace(".py", "")
 
DEFAULT_ARGS = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
}
 
SPARK_STEPS = [
    {
        'Name': 'ram_spark_step1',
        'ActionOnFailure': 'CONTINUE',
        'HadoopJarStep': {
            'Jar': 'command-runner.jar',
            'Args': ["spark-submit",
                "--class", "org.apache.spark.examples.SparkPi",
                "--master", "yarn",
                "--deploy-mode", "cluster",
                "--executor-memory", "4G",
                "--num-executors", "6",
                "--queue", "default",
                "/usr/lib/spark/examples/jars/spark-examples.jar", "10"],
        },
    },
    {
        'Name': 'ram_spark_step2',
        'ActionOnFailure': 'CONTINUE',
        'HadoopJarStep': {
            'Jar': 'command-runner.jar',
            'Args': ["spark-submit",
                "--class", "org.apache.spark.examples.SparkPi",
                "--master", "yarn",
                "--deploy-mode", "cluster",
                "--executor-memory", "4G",
                "--num-executors", "6",
                "--queue", "bda",
                "/usr/lib/spark/examples/jars/spark-examples.jar", "100"],
        },
    },
    {
        'Name': 'ram_spark_step3',
        'ActionOnFailure': 'CONTINUE',
        'HadoopJarStep': {
            'Jar': 'command-runner.jar',
            'Args': ["spark-submit",
                "--class", "org.apache.spark.examples.SparkPi",
                "--master", "yarn",
                "--deploy-mode", "cluster",
                "--executor-memory", "4G",
                "--num-executors", "6",
                "--queue", "fods",
                "/usr/lib/spark/examples/jars/spark-examples.jar", "1000"],
        },
    },
    {
        'Name': 'ram_spark_step4',
        'ActionOnFailure': 'CONTINUE',
        'HadoopJarStep': {
            'Jar': 'command-runner.jar',
            'Args': ["bash", "-c", "aws s3 cp s3://ramtest-admin-data/transient/scripts/spark-sparkpi.sh /home/hadoop", "chmod +x /home/hadoop/spark-sparkpi.sh", "cd /home/hadoop", "./spark-sparkpi.sh"],
        },
    },
    {
        'Name': 'ram_spark_step5',
        'ActionOnFailure': 'CONTINUE',
        'HadoopJarStep': {
            'Jar': 'command-runner.jar',
            'Args': ["bash", "-c", "aws s3 cp s3://ramtest-admin-data/transient/scripts/spark-sparkpi.sh /home/hadoop/spark-sparkpi1.sh", "chmod +x /home/hadoop/spark-sparkpi1.sh", "cd /home/hadoop", "./spark-sparkpi1.sh"],
        },
    },
    {
        'Name': 'ram_hive_step6',
        'ActionOnFailure': 'CONTINUE',
        'HadoopJarStep': {
            'Jar': 'command-runner.jar',
            'Args': ["hive-script","--run-hive-script", "--args","-f","s3://ramtest-admin-data/transient/scripts/hive.sql"],
        },
    },
    {
        'Name': 'ram_hive_step7',
        'ActionOnFailure': 'CONTINUE',
        'HadoopJarStep': {
            'Jar': 'command-runner.jar',
            'Args': ["hive-script","--run-hive-script", "--args","-f","s3://ramtest-admin-data/transient/scripts/hive1.sql"],
        },
    },
    {
        'Name': 'ram_hive_step8',
        'ActionOnFailure': 'CONTINUE',
        'HadoopJarStep': {
            'Jar': 'command-runner.jar',
            'Args': ["hive-script","--run-hive-script", "--args","-f","s3://ramtest-admin-data/transient/scripts/hive2.sql"],
        },
    }
]
 
JOB_FLOW_OVERRIDES = {
    'Name': 'ramtest-mwaa-demo-cluster',
    'ReleaseLabel': 'emr-6.15.0',
    'Applications': [{'Name': 'Spark'}, {'Name': 'Hive'}, {'Name': 'Hadoop'}],
    'LogUri': 's3://ramtest-aws-logs/elasticmapreduce/',
    'StepConcurrencyLevel': 4,
    'Configurations': [
       {
          "Classification": "hive-env",
          "Properties": {},
          "Configurations": [
             {
                "Classification": "export",
                "Properties": {
                  "HADOOP_HEAPSIZE": "2048"
                }
             }
          ]
       },
       {
          "Classification": "hive-site",
          "Properties": {
             "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory",
             "mapreduce.job.queuename": "bda",
             "tez.queue.name": "bda",
             "hive.server2.thrift.max.worker.threads": "2000",
             "hive.server2.thrift.worker.keepalive.time": "120s"
          }
       },
       {
          "Classification": "spark-hive-site",
          "Properties": {
             "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
          }
       },
       {
          "Classification": "spark-defaults",
          "Properties": {
             "spark.dynamicAllocation.enabled": "false",
             "spark.executor.instances": "5",
             "spark.executor.memory": "2G",
             "spark.executor.cores": "2",
             "spark.yarn.queue": "bda",
             "spark.yarn.heterogeneousExecutors.enabled": "false",
             "spark.eventLog.enabled": "true",
             "spark.eventLog.dir": "s3://ramtest-aws-logs/ramtest-spark-logs/",
             "spark.history.fs.logDirectory": "s3://ramtest-aws-logs/ramtest-spark-logs/"
           }
       },
       {
          "Classification": "mapred-site",
          "Properties": {
             "mapreduce.job.queuename": "bda",
             "mapred.tasktracker.map.tasks.maximum": "4"
          }
       },
       {
          "Classification": "yarn-site",
          "Properties": {
             "yarn.resourcemanager.scheduler.class": "org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler",
             "yarn.resourcemanager.scheduler.monitor.enable": "true",
             "yarn.resourcemanager.scheduler.monitor.policies": "org.apache.hadoop.yarn.server.resourcemanager.monitor.capacity.ProportionalCapacityPreemptionPolicy",
             "yarn.resourcemanager.monitor.capacity.preemption.monitoring_interval": "3000",
             "yarn.resourcemanager.monitor.capacity.preemption.max_wait_before_kill": "15000",
             "yarn.resourcemanager.monitor.capacity.preemption.total_preemption_per_round": "0.1",
             "yarn.resourcemanager.monitor.capacity.preemption.max_ignored_over_capacity": "0.1",
             "yarn.resourcemanager.monitor.capacity.preemption.natural_termination_factor": "1.0",
             "yarn.resourcemanager.monitor.capacity.preemption.intra-queue-preemption.enabled": "true",
             "yarn.cluster.max-application-priority": "100",
             "yarn.acl.enable": "false",
             "yarn.log-aggregation-enable": "true",
             "yarn.log-aggregation.retain-seconds": "-1",
             "yarn.nodemanager.remote-app-log-dir": "s3://ramtest-aws-logs/ramtest-yarn-logs/",
             "yarn.node-labels.enabled": "true",
             "yarn.node-labels.am.default-node-label-expression": "CORE"
           }
       },
       {
          "Classification": "hdfs-site",
          "Properties": {
             "dfs.replication": "3",
             "dfs.namenode.handler.count": "40"
          }
       },
       {
          "Classification": "capacity-scheduler",
          "Properties": {
             "yarn.scheduler.capacity.root.default.ordering-policy": "fair",
             "yarn.scheduler.capacity.root.queues": "default,bda,fods",
             "yarn.scheduler.capacity.root.capacity": "100",
             "yarn.scheduler.capacity.root.default.capacity": "25",
             "yarn.scheduler.capacity.root.default.maximum-capacity": "50",
             "yarn.scheduler.capacity.root.default.minimum-user-limit-percent": "10",
             "yarn.scheduler.capacity.root.default.user-limit-factor": "3",
             "yarn.scheduler.capacity.root.default.maximum-am-resource-percent": "10",
             "yarn.scheduler.capacity.root.default.acl_submit_applications": "*",
             "yarn.scheduler.capacity.root.default.acl_administer_queue": "*",
             "yarn.scheduler.capacity.root.bda.capacity": "25",
             "yarn.scheduler.capacity.root.bda.maximum-capacity": "50",
             "yarn.scheduler.capacity.root.bda.ordering-policy": "fair",
             "yarn.scheduler.capacity.root.bda.minimum-user-limit-percent": "10",
             "yarn.scheduler.capacity.root.bda.user-limit-factor": "3",
             "yarn.scheduler.capacity.root.bda.maximum-am-resource-percent": "10",
             "yarn.scheduler.capacity.root.bda.acl_submit_applications": "*",
             "yarn.scheduler.capacity.root.bda.acl_administer_queue": "*",
             "yarn.scheduler.capacity.root.fods.capacity": "50",
             "yarn.scheduler.capacity.root.fods.maximum-capacity": "100",
             "yarn.scheduler.capacity.root.fods.ordering-policy": "fair",
             "yarn.scheduler.capacity.root.fods.minimum-user-limit-percent": "10",
             "yarn.scheduler.capacity.root.fods.user-limit-factor": "3",
             "yarn.scheduler.capacity.root.fods.maximum-am-resource-percent": "10",
             "yarn.scheduler.capacity.root.fods.acl_submit_applications": "*",
             "yarn.scheduler.capacity.root.fods.acl_administer_queue": "*",
             "yarn.scheduler.capacity.resource-calculator": "org.apache.hadoop.yarn.util.resource.DominantResourceCalculator",
             "yarn.scheduler.capacity.maximum-am-resource-percent": "10",
             "yarn.scheduler.capacity.schedule-asynchronously.enable": "true",
             "yarn.scheduler.capacity.queue-mappings": "g:root:default,g:root:bda,g:root:fods",
             "yarn.scheduler.capacity.root.accessible-node-labels.CORE.capacity": "100",
             "yarn.scheduler.capacity.root.default.accessible-node-labels.CORE.capacity": "25",
             "yarn.scheduler.capacity.root.bda.accessible-node-labels.CORE.capacity": "25",
             "yarn.scheduler.capacity.root.fods.accessible-node-labels.CORE.capacity": "50"
          },
          "Configurations": []
       },
    ],
    'Instances': {
        'InstanceGroups': [
            {
                'Name': "Master nodes",
                'Market': 'ON_DEMAND',
                'InstanceRole': 'MASTER',
                'InstanceType': 'c5a.xlarge',
                'InstanceCount': 1,
                'EbsConfiguration': {
                   'EbsBlockDeviceConfigs': [
                      {
                         'VolumeSpecification': {
                            'VolumeType': 'gp3',
                            'Iops': 3000,
                            'SizeInGB': 100,
                            'Throughput': 500,
                         },
                         'VolumesPerInstance': 2,
                      },
                   ],
                   'EbsOptimized': True,
                },
            },
            {
                'Name': "Core nodes",
                'Market': 'ON_DEMAND',
                'InstanceRole': 'CORE',
                'InstanceType': 'c5a.xlarge',
                'InstanceCount': 2,
                'EbsConfiguration': {
                   'EbsBlockDeviceConfigs': [
                      {
                         'VolumeSpecification': {
                            'VolumeType': 'gp3',
                            'Iops': 3000,
                            'SizeInGB': 100,
                            'Throughput': 500,
                         },
                         'VolumesPerInstance': 2,
                      },
                   ],
                   'EbsOptimized': True,
                },
            },
            {
                'Name': "Task nodes",
                'Market': 'SPOT',
                'InstanceRole': 'TASK',
                'InstanceType': 'c5a.xlarge',
                'InstanceCount': 1,
                'EbsConfiguration': {
                   'EbsBlockDeviceConfigs': [
                      {
                         'VolumeSpecification': {
                            'VolumeType': 'gp3',
                            'Iops': 3000,
                            'SizeInGB': 100,
                            'Throughput': 500,
                         },
                         'VolumesPerInstance': 2,
                      },
                   ],
                   'EbsOptimized': True,
                },
            },
        ],
        'KeepJobFlowAliveWhenNoSteps': False,
        'TerminationProtected': False,
        'Ec2KeyName': 'svc-bdadmin-smdh-dev',
        'Ec2SubnetIds': [ 'subnet-08d451811b8709df0',],
    },
    'ManagedScalingPolicy' : {
           'ComputeLimits': {
              'UnitType': 'Instances',
              'MinimumCapacityUnits': 2,
              'MaximumCapacityUnits': 5,
              'MaximumOnDemandCapacityUnits': 2,
              'MaximumCoreCapacityUnits': 2,
           }
    },
    'VisibleToAllUsers': True,
    'JobFlowRole': 'BaseInstanceProfileV3',
    'ServiceRole': 'ramtest-emr-6.15.0-EMRClusterServiceRole',
    'BootstrapActions': [
       {
          'Name': 'install-ssm-agent',
          'ScriptBootstrapAction': {
             'Path': 's3://ramtest-admin-data/scripts/install-ssm.sh'
          }
       },
       {
          'Name': 'setup-post-provisioning',
          'ScriptBootstrapAction': {
             'Path': 's3://ramtest-admin-data/scripts/setup_post-provisioning.sh',
             'Args': ["ramtest", "svc-bdadmin-smdh-dev"]
          }
       }
    ]
}
 
with DAG(
    dag_id=DAG_ID,
    default_args=DEFAULT_ARGS,
    dagrun_timeout=timedelta(hours=2),
    start_date=days_ago(1),
    schedule_interval='@once',
    tags=['emr'],
) as dag:
 
    start_pipeline = DummyOperator(task_id="start_pipeline", dag=dag)
    
    cluster_creator = EmrCreateJobFlowOperator(
        task_id='create_job_flow',
        pool='ramtest-pool2',
        job_flow_overrides=JOB_FLOW_OVERRIDES
    )
 
    step_adder = EmrAddStepsOperator(
        task_id='add_steps',
        job_flow_id="{{ task_instance.xcom_pull(task_ids='create_job_flow', key='return_value') }}",
        aws_conn_id='aws_default',
        pool='ramtest-pool2',
        steps=SPARK_STEPS,
    )
 
    step_checker = EmrStepSensor(
        task_id='watch_step',
        job_flow_id="{{ task_instance.xcom_pull('create_job_flow', key='return_value') }}",
        step_id="{{ task_instance.xcom_pull(task_ids='add_steps', key='return_value')[0] }}",
        aws_conn_id='aws_default',
        pool='ramtest-pool2',
        dag = dag,
    )
 
    end_pipeline = DummyOperator(task_id="end_pipeline", dag=dag)
    
    #cluster_creator >> step_adder >> step_checker 
    start_pipeline >> cluster_creator >> step_adder >> step_checker >> end_pipeline 