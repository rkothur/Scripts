/* working - displays only topic name */
output "topic_details" {
    value = [
        for topic in kafka_topic.topics : topic.name 
    ]
}

output "topic_details1" {
    value = [
        for topic in kafka_topic.topics1 : topic.name 
    ]
}

output "topic_acls1" {
    value = [kafka_acl.global_topic_describe]
}

output "topic_acls2" {
    value = [kafka_acl.global_cg_describe]
}

output "topic_acls3" {
    value = [kafka_acl.user_topic_idempotentwrite]
}

output "topic_acls4" {
    value = [kafka_acl.user_topic_write]
}

output "topic_acls5" {
    value = [kafka_acl.user_topic_read]
}

output "topic_acls6" {
    value = [kafka_acl.user_group_read]
}


/*
output "topic_details" {
    value = [
        for topic in kafka_topic.topics :
           jsondecode(topic.topics_json).name,
           jsondecode(topic.topics_json).partitions,
           jsondecode(topic.topics_json).replication_factor  
    ]
}
*/