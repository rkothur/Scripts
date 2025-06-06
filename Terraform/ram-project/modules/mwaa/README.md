# MWAA Terraform deployment

1. Update the environments/platform-code-dev.tfvars file
2. Update the requirements.txt and plugins.zip if required
3. Run the mwaa-s3 code to create the MWAA S3 bucket
4. Run this code 


mwaa-iam.tf
delete from line 96

resources = var.kms_key_arn != null ? [
      var.kms_key_arn
    ] : []
    not_resources = var.kms_key_arn == null ? [
      "arn:aws:kms:*:${var.account_no}:key/*"
    ] : []
    condition {
      test = "StringLike"
      values = var.kms_key_arn != null ? [
        "sqs.${var.aws_region}.amazonaws.com",
        "s3.${var.aws_region}.amazonaws.com"
      ] : [
        "sqs.${var.aws_region}.amazonaws.com"
      ]
      variable = "kms:ViaService"
    }