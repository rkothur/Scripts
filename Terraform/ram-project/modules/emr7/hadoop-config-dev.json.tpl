[
  {
    "Classification": "hive-env",
    "Properties": {},
    "Configurations": [
      {
        "Classification": "export",
        "Properties": {
          "HADOOP_HEAPSIZE": "4096"
        }
      }
    ]
  },
  {
    "Classification": "hive-site",
    "Properties": {
      "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory",
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
      "spark.dynamicAllocation.enabled": "true",
      "spark.executor.instances": "5",
      "spark.executor.memory": "2G",
      "spark.executor.cores": "2",
      "spark.yarn.heterogeneousExecutors.enabled": "false",
      "spark.eventLog.enabled": "true",
      "spark.eventLog.dir": "s3://sdh-smdh-dev-aws-logs/spark-logs/",
      "spark.history.fs.logDirectory": "s3://sdh-smdh-dev-aws-logs/spark-logs/",
      "spark.yarn.am.nodeLabelExpression": "CORE"
    }
  },
  {
    "Classification": "spark-env",
    "Properties": {
      "SPARK_DAEMON_MEMORY": "4g"
    }
  },
  {
    "Classification": "mapred-site",
    "Properties": {
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
      "yarn.nodemanager.remote-app-log-dir": "s3://sdh-smdh-dev-aws-logs/yarn-logs/",
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
      "yarn.scheduler.capacity.root.queues": "default,bda,bal,mob2bi,ordl,mob,msl,baus,ctm2",
      "yarn.scheduler.capacity.root.capacity": "100",
	    "yarn.scheduler.capacity.root.default.capacity": "2",
      "yarn.scheduler.capacity.root.default.maximum-capacity": "100",
      "yarn.scheduler.capacity.root.default.minimum-user-limit-percent": "10",
      "yarn.scheduler.capacity.root.default.user-limit-factor": "3",
      "yarn.scheduler.capacity.root.default.maximum-am-resource-percent": "10",
      "yarn.scheduler.capacity.root.default.acl_submit_applications": "*",
      "yarn.scheduler.capacity.root.default.acl_administer_queue": "*",
	    "yarn.scheduler.capacity.root.bda.capacity": "3",
      "yarn.scheduler.capacity.root.bda.maximum-capacity": "60",
      "yarn.scheduler.capacity.root.bda.ordering-policy": "fair",
      "yarn.scheduler.capacity.root.bda.minimum-user-limit-percent": "10",
      "yarn.scheduler.capacity.root.bda.user-limit-factor": "3",
      "yarn.scheduler.capacity.root.bda.maximum-am-resource-percent": "10",
      "yarn.scheduler.capacity.root.bda.acl_submit_applications": "*",
      "yarn.scheduler.capacity.root.bda.acl_administer_queue": "*",
	    "yarn.scheduler.capacity.root.bal.capacity": "30",
      "yarn.scheduler.capacity.root.bal.maximum-capacity": "100",
      "yarn.scheduler.capacity.root.bal.ordering-policy": "fair",
      "yarn.scheduler.capacity.root.bal.minimum-user-limit-percent": "10",
      "yarn.scheduler.capacity.root.bal.user-limit-factor": "3",
      "yarn.scheduler.capacity.root.bal.maximum-am-resource-percent": "10",
      "yarn.scheduler.capacity.root.bal.acl_submit_applications": "*",
      "yarn.scheduler.capacity.root.bal.acl_administer_queue": "*",
	    "yarn.scheduler.capacity.root.mob2bi.capacity": "25",
      "yarn.scheduler.capacity.root.mob2bi.maximum-capacity": "100",
      "yarn.scheduler.capacity.root.mob2bi.ordering-policy": "fair",
      "yarn.scheduler.capacity.root.mob2bi.minimum-user-limit-percent": "10",
      "yarn.scheduler.capacity.root.mob2bi.user-limit-factor": "3",
      "yarn.scheduler.capacity.root.mob2bi.maximum-am-resource-percent": "10",
      "yarn.scheduler.capacity.root.mob2bi.acl_submit_applications": "*",
      "yarn.scheduler.capacity.root.mob2bi.acl_administer_queue": "*",
	    "yarn.scheduler.capacity.root.ordl.capacity": "10",
      "yarn.scheduler.capacity.root.ordl.maximum-capacity": "100",
      "yarn.scheduler.capacity.root.ordl.ordering-policy": "fair",
      "yarn.scheduler.capacity.root.ordl.minimum-user-limit-percent": "10",
      "yarn.scheduler.capacity.root.ordl.user-limit-factor": "3",
      "yarn.scheduler.capacity.root.ordl.maximum-am-resource-percent": "10",
      "yarn.scheduler.capacity.root.ordl.acl_submit_applications": "*",
      "yarn.scheduler.capacity.root.ordl.acl_administer_queue": "*",
	    "yarn.scheduler.capacity.root.mob.capacity": "15",
      "yarn.scheduler.capacity.root.mob.maximum-capacity": "100",
      "yarn.scheduler.capacity.root.mob.ordering-policy": "fair",
      "yarn.scheduler.capacity.root.mob.minimum-user-limit-percent": "10",
      "yarn.scheduler.capacity.root.mob.user-limit-factor": "3",
      "yarn.scheduler.capacity.root.mob.maximum-am-resource-percent": "10",
      "yarn.scheduler.capacity.root.mob.acl_submit_applications": "*",
      "yarn.scheduler.capacity.root.mob.acl_administer_queue": "*",
		  "yarn.scheduler.capacity.root.msl.capacity": "5",
      "yarn.scheduler.capacity.root.msl.maximum-capacity": "100",
      "yarn.scheduler.capacity.root.msl.ordering-policy": "fair",
      "yarn.scheduler.capacity.root.msl.minimum-user-limit-percent": "10",
      "yarn.scheduler.capacity.root.msl.user-limit-factor": "3",
      "yarn.scheduler.capacity.root.msl.maximum-am-resource-percent": "10",
      "yarn.scheduler.capacity.root.msl.acl_submit_applications": "*",
      "yarn.scheduler.capacity.root.msl.acl_administer_queue": "*",
		  "yarn.scheduler.capacity.root.baus.capacity": "5",
      "yarn.scheduler.capacity.root.baus.maximum-capacity": "100",
      "yarn.scheduler.capacity.root.baus.ordering-policy": "fair",
      "yarn.scheduler.capacity.root.baus.minimum-user-limit-percent": "10",
      "yarn.scheduler.capacity.root.baus.user-limit-factor": "3",
      "yarn.scheduler.capacity.root.baus.maximum-am-resource-percent": "10",
      "yarn.scheduler.capacity.root.baus.acl_submit_applications": "*",
      "yarn.scheduler.capacity.root.baus.acl_administer_queue": "*",
	 	  "yarn.scheduler.capacity.root.ctm2.capacity": "5",
      "yarn.scheduler.capacity.root.ctm2.maximum-capacity": "100",
      "yarn.scheduler.capacity.root.ctm2.ordering-policy": "fair",
      "yarn.scheduler.capacity.root.ctm2.minimum-user-limit-percent": "10",
      "yarn.scheduler.capacity.root.ctm2.user-limit-factor": "3",
      "yarn.scheduler.capacity.root.ctm2.maximum-am-resource-percent": "10",
      "yarn.scheduler.capacity.root.ctm2.acl_submit_applications": "*",
      "yarn.scheduler.capacity.root.ctm2.acl_administer_queue": "*",
	    "yarn.scheduler.capacity.resource-calculator": "org.apache.hadoop.yarn.util.resource.DominantResourceCalculator",
      "yarn.scheduler.capacity.maximum-am-resource-percent": "10",
      "yarn.scheduler.capacity.schedule-asynchronously.enable": "true",
      "yarn.scheduler.capacity.queue-mappings": "g:root:default,g:root:bda,g:root:bal,g:root:mob2bi,g:root:ordl,g:root:mob,g:root:msl,g:root:baus,g:root:ctm2",
      "yarn.scheduler.capacity.root.accessible-node-labels.CORE.capacity": "100",
      "yarn.scheduler.capacity.root.default.accessible-node-labels.CORE.capacity": "2",
      "yarn.scheduler.capacity.root.bda.accessible-node-labels.CORE.capacity": "3",
      "yarn.scheduler.capacity.root.bal.accessible-node-labels.CORE.capacity": "30",
      "yarn.scheduler.capacity.root.mob2bi.accessible-node-labels.CORE.capacity": "25",
      "yarn.scheduler.capacity.root.ordl.accessible-node-labels.CORE.capacity": "10",
      "yarn.scheduler.capacity.root.mob.accessible-node-labels.CORE.capacity": "15",
      "yarn.scheduler.capacity.root.msl.accessible-node-labels.CORE.capacity": "5",
      "yarn.scheduler.capacity.root.baus.accessible-node-labels.CORE.capacity": "5",
      "yarn.scheduler.capacity.root.ctm2.accessible-node-labels.CORE.capacity": "5"
    },
    "Configurations": []
  },
  {
    "Classification": "delta-defaults",
    "Properties": {
      "delta.enabled": "true"
    }
  },
  {
    "Classification": "trino-connector-delta",
    "Properties": {
      "hive.metastore": "glue",
      "connector.name":"hive"
    }
  },
  {
    "Classification": "iceberg-defaults",
    "Properties": {
      "iceberg.enabled": "true"
    }
  } 
 ]