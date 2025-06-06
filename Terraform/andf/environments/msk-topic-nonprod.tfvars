##### Tags #####
tag_Tech = "terraform"
tag_Stack = "terraform"
tag_Team = "dp-sdh-pe"
tag_Solution = "sdl"
tag_App = "msk"
tag_Function = "msk"
tag_Env = "dev"
tag_Org = "data-platforms"
tag_Group = "sdh"
tag_Cost-code = "532"

##### Region #####
region = "us-east-1"

##### Prefix #####
prefix = "ramtest"

##### Kafka Parameters #####
aws_profile = "andf-nonprod"
sasl_mechanism = "aws-iam"
tls_enabled = false
bootstrap_servers = ["b-2.sdhsdlmskkafkatest.j2h5wv.c8.kafka.us-east-1.amazonaws.com:9098","b-1.sdhsdlmskkafkatest.j2h5wv.c8.kafka.us-east-1.amazonaws.com:9098","b-3.sdhsdlmskkafkatest.j2h5wv.c8.kafka.us-east-1.amazonaws.com:9098"]

topic_list = [
    {
       "name": "ramtest_tp2",
       "partitions" : "2",
       "replication_factor" : "1"
    },
    {
       "name": "ramtest_tp3",
       "partitions" : "1",
       "replication_factor" : "3"
    },
    {
       "name": "ramtest_tp4",
       "partitions" : "3",
       "replication_factor" : "3"
    },
    {
       "name": "ramtest_tp6",
       "partitions" : "5",
       "replication_factor" : "3"
    }
  ]

  topic_list1 = [
    {
       "name": "ramtest_tp7",
       "partitions" : "50",
       "replication_factor" : "3"
    },
    {
       "name": "ramtest_tp8",
       "partitions" : "100",
       "replication_factor" : "3"
    },
    {
       "name": "ramtest_tp9",
       "partitions" : "10",
       "replication_factor" : "2"
    }
  ]