resource "aws_emr_cluster" "EMR" {
    name = "${var.prefix}-${var.emr7_release}"
    release_label = var.emr7_release
    applications = var.emr7_applications[*]
    configurations_json = file("${var.emr7_hadoop_configurations_json}")
    termination_protection = true
    //termination_protection = false
    keep_job_flow_alive_when_no_steps = true
    //custom_ami_id = data.aws_ami.proxy_ami.id
    service_role = var.emr7_EMRClusterServiceRole_arn
    ebs_root_volume_size   = var.emr7_root_volume_size
    depends_on = [
      var.emr7_instance_profile,
      var.emr7_EMRClusterInstanceProfileRole,
      var.emr7_EMRClusterServiceRole
    ]
    log_uri = "s3://${var.prefix}-aws-logs/elasticmapreduce"
    
    /*
    step {
    action_on_failure = "TERMINATE_CLUSTER"
    name              = "Setup Hadoop Debugging"
    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["state-pusher-script"]
    }
    }
   */

    ec2_attributes {
      subnet_ids = var.priv_subnets[*]
      instance_profile = var.emr7_instance_profile
      key_name = var.emr7_key_name
      service_access_security_group      = var.emr7_service_access_sg
      emr_managed_slave_security_group  = var.emr7_worker_sg
      emr_managed_master_security_group = var.emr7_master_sg
     
    }

  bootstrap_action {
    path = "s3://${var.prefix}-admin-data/scripts/install-ssm.sh"
    name = "ssm-agent"
  }
  
  bootstrap_action {
    path = "s3://${var.prefix}-admin-data/scripts/setup_post-provisioning.sh"
    name = "setup-post-provisioning"
    args = ["${var.prefix}", "${var.emr7_app_user_keyname}"]
  }

  /*bootstrap_action {
    path = "s3://${var.prefix}-admin-data/files/trino-copy-files.sh"
    name = "copy-trino-configs"
    args = ["${var.prefix}", "${var.app_user_keyname}"]
  }*/

  bootstrap_action {
    path = "s3://${var.prefix}-admin-data/scripts/datadog_job_mont_init.sh"
    #path = "s3://sdh-smdh-admin-data/scripts/install-ssm.sh"
    name = "datadog-agent"
    args = ["${var.prefix}", "${var.emr7_app_user_keyname}"]
  }
  bootstrap_action {
    path = "s3://${var.prefix}-admin-data/scripts/replace-node-provisioner-ba.sh"
    name = "nodeprovisioner fix for label + queue"
    args = ["s3://${var.prefix}-admin-data/scripts/node-provisioner-emr-7.0.0.jar"]
 	}

  tags = merge(
      var.tags,
      {
        Name = "${var.prefix}-EMR"
      }
  )

  placement_group_config = [
    {
      instance_role = "MASTER"
      placement_strategy = "SPREAD"
    }
  ]

  master_instance_fleet {
    instance_type_configs {
        bid_price_as_percentage_of_on_demand_price = 100
        ebs_config {
           size = var.emr7_ebs_size
           type = var.emr7_ebs_type
           volumes_per_instance = var.emr7_ebs_disk_count
        }
        instance_type = var.emr7_master_instance_type
        weighted_capacity = 1
    }
    target_on_demand_capacity = var.emr7_master_node_count
    name = "master_if"
  }

  core_instance_fleet {
    instance_type_configs {
       bid_price_as_percentage_of_on_demand_price = 100
       ebs_config {
          size = var.emr7_ebs_size
          type = var.emr7_ebs_type
          volumes_per_instance = var.emr7_ebs_disk_count
        }
        instance_type = var.emr7_core_instance_type1
        weighted_capacity = 1
    }
    instance_type_configs {
       bid_price_as_percentage_of_on_demand_price = 100
       ebs_config {
          size = var.emr7_ebs_size
          type = var.emr7_ebs_type
          volumes_per_instance = var.emr7_ebs_disk_count
        }
       instance_type = var.emr7_core_instance_type2
       weighted_capacity = 1
    }   
    instance_type_configs {
       bid_price_as_percentage_of_on_demand_price = 100
       ebs_config {
          size = var.emr7_ebs_size
          type = var.emr7_ebs_type
          volumes_per_instance = var.emr7_ebs_disk_count
        }
       instance_type = var.emr7_core_instance_type3
       weighted_capacity = 1
    }
    launch_specifications {
      on_demand_specification {
        allocation_strategy = "lowest-price" 
      }
    }
    target_on_demand_capacity = var.emr7_core_node_count
    target_spot_capacity = 0
    name = "core_if"
   }
}

resource "aws_emr_instance_fleet" "task_instance_fleet" {
  cluster_id = "${aws_emr_cluster.EMR.id}"
  instance_type_configs {
         bid_price_as_percentage_of_on_demand_price = 100
         ebs_config {
            size = var.emr7_ebs_size
            type = var.emr7_ebs_type
            volumes_per_instance = var.emr7_ebs_disk_count
            }
         instance_type = var.emr7_task_instance_type1
         weighted_capacity = 1
      }
      instance_type_configs {
         bid_price_as_percentage_of_on_demand_price = 100
         ebs_config {
            size = var.emr7_ebs_size
            type = var.emr7_ebs_type
            volumes_per_instance = var.emr7_ebs_disk_count
          }
         instance_type = var.emr7_task_instance_type2
         weighted_capacity = 1
      }   
      instance_type_configs {
         bid_price_as_percentage_of_on_demand_price = 100
         ebs_config {
            size = var.emr7_ebs_size
            type = var.emr7_ebs_type
            volumes_per_instance = var.emr7_ebs_disk_count
          }
         instance_type = var.emr7_task_instance_type3
         weighted_capacity = 1
      }
    launch_specifications {
      spot_specification {
        allocation_strategy = "capacity-optimized"
        timeout_duration_minutes = 10
        timeout_action = "SWITCH_TO_ON_DEMAND"
      }
      on_demand_specification {
        allocation_strategy = "lowest-price"
      }
    }
    target_on_demand_capacity = var.emr7_task_node_min_count
    name = "task_if"
}

resource "aws_emr_managed_scaling_policy" "ManagedScalingPolicy" {
  cluster_id = aws_emr_cluster.EMR.id
  compute_limits {
    unit_type = "InstanceFleetUnits"
    minimum_capacity_units = sum([tonumber(var.emr7_core_node_count), tonumber(var.emr7_task_node_min_count)])
    maximum_capacity_units = sum([tonumber(var.emr7_core_node_count), tonumber(var.emr7_task_node_max_count)])
    maximum_ondemand_capacity_units = sum([tonumber(var.emr7_core_node_count), tonumber(var.emr7_task_ondemand_node_count)])
    maximum_core_capacity_units = var.emr7_core_node_count
  }
  depends_on = [ aws_emr_cluster.EMR ]
}
