resource "kafka_acl" "global_topic_describe" {
  depends_on = [ kafka_topic.topics, kafka_topic.topics1 ]
  resource_name = "*"
  resource_type = "Topic"
  acl_principal = "User:*"
  acl_host = "*"
  acl_operation = "Describe"
  acl_permission_type = "Allow"
  resource_pattern_type_filter = "Prefixed"
}

resource "kafka_acl" "global_cg_describe" {
  depends_on = [ kafka_topic.topics, kafka_topic.topics1 ]
  resource_name = "*"
  resource_type = "Group"
  acl_principal = "User:*"
  acl_host = "*"
  acl_operation = "Describe"
  acl_permission_type = "Allow"
  resource_pattern_type_filter = "Prefixed"
}

resource "kafka_acl" "user_topic_idempotentwrite" {
  depends_on = [ kafka_topic.topics, kafka_topic.topics1 ]
  resource_name = "ramtest_tp*"
  resource_type = "Topic"
  acl_principal = "User:rkothur"
  acl_host = "*"
  acl_operation = "IdempotentWrite"
  acl_permission_type = "Allow"
  resource_pattern_type_filter = "Prefixed"
}

resource "kafka_acl" "user_topic_write" {
  depends_on = [ kafka_topic.topics, kafka_topic.topics1 ]
  resource_name = "ramtest_tp*"
  resource_type = "Topic"
  acl_principal = "User:rkothur"
  acl_host = "*"
  acl_operation = "Write"
  acl_permission_type = "Allow"
  resource_pattern_type_filter = "Prefixed"
}

resource "kafka_acl" "user_topic_read" {
  depends_on = [ kafka_topic.topics, kafka_topic.topics1 ]
  resource_name = "ramtest_tp*"
  resource_type = "Topic"
  acl_principal = "User:balram"
  acl_host = "*"
  acl_operation = "Read"
  acl_permission_type = "Allow"
  resource_pattern_type_filter = "Prefixed"
}

resource "kafka_acl" "user_group_read" {
  depends_on = [ kafka_topic.topics, kafka_topic.topics1 ]
  resource_name = "console_consumer*"
  resource_type = "Group"
  acl_principal = "User:balram"
  acl_host = "*"
  acl_operation = "Read"
  acl_permission_type = "Allow"
  resource_pattern_type_filter = "Prefixed"
}