# Terraform to create Topics in AWS MSK

**Link to module:** https://github.com/Mongey/terraform-provider-kafka

### Changes to be made before executing the script #####

#### main.tf:

-Change Terraform bucket, key and value

#### variables.tf

-Make the necessary changes to different values 

#### outputs.tf

-No changes needed

#### kafka-topics.tf

- This file creates all the necessary topics
-Change bootstrap servers, sasl_aws_profile, 

#### kafka-acls.tf

- This file creates the acls for the kafka topics, groups, etc

#### Commands:

1. Login using sso script
2. $env:AWS_PROFILE=<account>
3. terraform vaildate
4. terraform plan
5. terraform apply


#### ACL Permissions - examples

```
Property                    Description                                     Valid values
acl_principal               Principal that is being allowed or denied       *
acl_host                    Host from which principal listed in acl_principal will have access      *
acl_operation               Operation that is being allowed or denied       Unknown, Any, All, Read, Write, Create, Delete, Alter, Describe, ClusterAction, DescribeConfigs, AlterConfigs, IdempotentWrite
acl_permission_type         Type of permission                              Unknown, Any, Allow, Deny
resource_name               The name of the resource                        *
resource_type               The type of resource                            Unknown, Any, Topic, Group, Cluster, TransactionalID
resource_pattern_type_filter                                                Prefixed, Any, Match, Literal
```

#### Quota Example

```
resource "kafka_quota" "test" {
  entity_name       = "client1"
  entity_type       = "client-id"
  config = {
    "consumer_byte_rate" = "4000000"
    "producer_byte_rate" = "3500000"
  }
}

Property            Description
entity_name         The name of the entity
entity_type         The entity type (client-id, user, ip)
config              A map of string attributes for the entity
```