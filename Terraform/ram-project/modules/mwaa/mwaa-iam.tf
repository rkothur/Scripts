/* MWAA - Execution Role policy */

resource "aws_iam_role" "MWAAExecutionRole" {
  name               = "${var.prefix}-${var.mwaa_version}-mwaa-execution-role"
  assume_role_policy = <<EOF1
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "airflow-env.amazonaws.com",
                    "airflow.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF1

  tags = var.tags
}

resource "aws_iam_role_policy" "role-policy" {
  name   = "airflow-execution-role-policy"
  role   = aws_iam_role.MWAAExecutionRole.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "airflow:PublishMetrics",
            "Resource": "arn:aws:airflow:${var.aws_region}:${var.account_no}:environment/${var.prefix}-${var.mwaa_name}-mwaa"
        },
        {
            "Effect": "Deny",
            "Action": "s3:ListAllMyBuckets",
            "Resource": [
                "${var.mwaa_s3_bucket_arn}",
                "${var.mwaa_s3_bucket_arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject*",
                "s3:GetBucket*",
                "s3:List*"
            ],
            "Resource": [
                "${var.mwaa_s3_bucket_arn}",
                "${var.mwaa_s3_bucket_arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:GetLogRecord",
                "logs:GetLogGroupFields",
                "logs:GetQueryResults"
            ],
            "Resource": [
                "arn:aws:logs:${var.aws_region}:${var.account_no}:log-group:${var.prefix}-${var.mwaa_name}-mwaa*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogGroups"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:PutMetricData",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sqs:ChangeMessageVisibility",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes",
                "sqs:GetQueueUrl",
                "sqs:ReceiveMessage",
                "sqs:SendMessage"
            ],
            "Resource": "arn:aws:sqs:${var.aws_region}:*:airflow-celery-*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:DescribeKey",
                "kms:GenerateDataKey*",
                "kms:Encrypt"
            ],
            "NotResource": "arn:aws:kms:*:${var.account_no}:key/*",
            "Condition": {
                "StringLike": {
                    "kms:ViaService": [
                        "sqs.us-east-1.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
EOF
}

/* CI USER policy */

data "aws_iam_policy_document" "ci_user_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetEncryptionConfiguration",
    ]
    resources = [
      "${var.mwaa_s3_bucket_arn}",
      "${var.mwaa_s3_bucket_arn}/*"
    ]
  }
}
resource "aws_iam_user" "app_user" {
  name = "appusr_airflow_ci"
  path = "/"
  tags = var.tags
  
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.app_user.name
}

resource "aws_iam_user_policy" "user_policy" {
  name   = "airflow_ci_policy"
  user   = aws_iam_user.app_user.name
  policy = data.aws_iam_policy_document.ci_user_policy.json
}
