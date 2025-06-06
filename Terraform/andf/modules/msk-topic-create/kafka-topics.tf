
provider "kafka" {
  bootstrap_servers = var.bootstrap_servers
  tls_enabled = var.tls_enabled
  sasl_mechanism = var.sasl_mechanism
  sasl_aws_region = var.region
  sasl_aws_profile = var.aws_profile
  //sasl_aws_creds_debug = true
  //skip_tls_verify = true
}

resource "kafka_topic" "topics" {
  //source = "Mongey/kafka"
  for_each = {for topic in var.topic_list: topic.name => topic}

  name = "${each.value.name}"
  partitions = "${each.value.partitions}"
  replication_factor = "${each.value.replication_factor}"

  config = {
    "cleanup.policy" = "compact"
    "retention.ms" = "259200000"
  }
}

resource "kafka_topic" "topics1" {
  //source = "Mongey/kafka"
  for_each = {for topic in var.topic_list1: topic.name => topic}

  name = "${each.value.name}"
  partitions = "${each.value.partitions}"
  replication_factor = "${each.value.replication_factor}"

  config = {
    "cleanup.policy" = "compact,delete"
    "retention.ms" = "259200000"
    "max.message.bytes" = "2048588"
  }
}
