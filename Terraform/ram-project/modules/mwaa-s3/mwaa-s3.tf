resource "aws_s3_bucket" "managed-airflow-bucket" {
  bucket        = "${var.prefix}-${var.mwaa_s3_bucket_name}"
  force_destroy = "false"
  tags = var.tags
  
}

resource "aws_s3_bucket_versioning" "managed-airflow-bucket-versioning" {
  depends_on = [ aws_s3_bucket.managed-airflow-bucket ]
  bucket = aws_s3_bucket.managed-airflow-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket" {
    depends_on = [ aws_s3_bucket.managed-airflow-bucket ]
    bucket = aws_s3_bucket.managed-airflow-bucket.id
    rule {
       object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "s3_bucket" {
  depends_on = [ aws_s3_bucket_ownership_controls.s3_bucket ]
  bucket = aws_s3_bucket.managed-airflow-bucket.id
  acl = "private"
}

resource "aws_s3_bucket_public_access_block" "s3_bucket" {
    depends_on = [ aws_s3_bucket_ownership_controls.s3_bucket ]
    bucket = aws_s3_bucket.managed-airflow-bucket.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "s3_bucket" {
    depends_on = [ aws_s3_bucket_ownership_controls.s3_bucket ]
    bucket = aws_s3_bucket.managed-airflow-bucket.id
    name   = "EntireBucket"
    tiering {
       access_tier = "DEEP_ARCHIVE_ACCESS"
       days        = var.mwaa_s3_deep_archive_days
    }
    tiering {
       access_tier = "ARCHIVE_ACCESS"
       days        = var.mwaa_s3_archive_days
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket" {
  depends_on = [ aws_s3_bucket_ownership_controls.s3_bucket ]
  bucket = aws_s3_bucket.managed-airflow-bucket.id
  rule {
    id = "lifecycle-policy"
    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    //expiration {
    //  days = 7
    //}
    status = "Enabled"
  }
}

resource "aws_s3_object" "s3_bucket_objects" {
  bucket = aws_s3_bucket.managed-airflow-bucket.id
  acl = "private"
  key = "requirements.txt"
  source = "./requirements.txt"
}

resource "aws_s3_object" "s3_bucket_objects1" {
  bucket = aws_s3_bucket.managed-airflow-bucket.id
  acl = "private"
  key = "plugins.zip"
  source = "./plugins.zip"
}

resource "aws_s3_object" "s3_bucket_objects2" {
  bucket = aws_s3_bucket.managed-airflow-bucket.id
  acl = "private"
  key = "dags/airflow_hello_world1.py"
  source = "./airflow_hello_world1.py"
}