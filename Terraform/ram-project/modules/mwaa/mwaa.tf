resource "aws_mwaa_environment" "mwaa_cluster" {
  name = "${var.prefix}-${var.mwaa_name}-mwaa"
  airflow_version = var.mwaa_version
  environment_class = var.mwaa_node_type
  min_workers = var.mwaa_min_workers
  max_workers = var.mwaa_max_workers
  webserver_access_mode = var.mwaa_webserver_access_mode
  source_bucket_arn               = var.mwaa_s3_bucket_arn
  weekly_maintenance_window_start = var.mwaa_maintenance_window
  //webserver_access_mode           = var.mwaa_webserver_access_mode
  dag_s3_path = var.mwaa_dag_s3_path
  plugins_s3_path = var.mwaa_plugins_s3_path
  requirements_s3_path = var.mwaa_requirements_s3_path
  execution_role_arn = aws_iam_role.MWAAExecutionRole.arn
  tags = var.tags

  airflow_configuration_options = {
    "core.dag_file_processor_timeout"           = 150
    "core.dagbag_import_timeout"                = 90
  }

  network_configuration {
    security_group_ids = [aws_security_group.managed_airflow_sg.id]
    subnet_ids = var.mwaa_priv_subnets[*]
  }
  
  logging_configuration {
    dag_processing_logs {
      enabled   = var.mwaa_dag_processing_logs_enabled
      log_level = var.mwaa_dag_processing_logs_level
    }

    scheduler_logs {
      enabled   = var.mwaa_scheduler_logs_enabled
      log_level = var.mwaa_scheduler_logs_level
    }

    task_logs {
      enabled   = var.mwaa_task_logs_enabled
      log_level = var.mwaa_task_logs_level
    }

    webserver_logs {
      enabled   = var.mwaa_webserver_logs_enabled
      log_level = var.mwaa_webserver_logs_level
    }

    worker_logs {
      enabled   = var.mwaa_worker_logs_enabled
      log_level = var.mwaa_worker_logs_level
    }
  }

  lifecycle {
    ignore_changes = [
      requirements_s3_object_version,
      plugins_s3_object_version,
    ]
  }

}
