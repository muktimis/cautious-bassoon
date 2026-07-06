data "aws_caller_identity" "current" {}
resource "aws_s3_bucket" "config_bucket" {
    bucket = "config-bucket-1234"
  
}

resource "aws_s3_bucket_public_access_block" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# resource "aws_s3_account_public_access_block" "config_bucket" {
#     bucket = aws_s3_bucket.config_bucket.id
    
#     block_public_acls       = true
#     block_public_policy     = true
#     ignore_public_acls      = true
#     restrict_public_buckets = true
  
# }

resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket" {
    bucket = aws_s3_bucket.config_bucket.id
  
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  
}

data "aws_iam_policy_document" "config_bucket_policy" {
  statement {
    sid = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["config.amazonaws.com"]      
  }
  actions = ["s3:GetBucketAcl"]
  resources = [aws_s3_bucket.config_bucket.arn]
}
statement {
    sid = "AWSConfigBucketDelivery"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.config_bucket.arn}/*"]
    condition {
      test = "StringEquals"
      variable = "s3:x-amz-acl"
      values = ["bucket-owner-full-control"]
    }
  }

}

resource "aws_s3_bucket_policy" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  policy = data.aws_iam_policy_document.config_bucket_policy.json
  
}



resource "aws_iam_role" "config_Role" {
  name = "config_Role"

  assume_role_policy = jsonencode({
    version = "2012-10-17"
    statement = [{
        action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config_policy" {
    role = aws_iam_role.config_Role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
  
}

resource "aws_config_configuration_recorder" "recorder" {
  name = "default"
  role_arn = aws_iam_role.config_Role.arn

  recording_group {
    all_supported = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "channel" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket

  depends_on = [aws_config_configuration_recorder.recorder]
}

#IAM POLICY FOR CONFIG SERVICE

data "aws_iam_policy_document" "config_service_policy" {
  statement {
    effect = "Allow"
    actions = ["s3:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config_role" {
    name = "guardrail_config_Role"
    assume_role_policy = data.aws_iam_policy_document.config_service_policy.json
  
}

data "aws_iam_policy_document" "config_s3_delivery" {
    statement {
      effect = "Allow"
      actions = ["s3:PutObject"]
      resources = ["${aws_s3_bucket.config_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config*"]

    }
  statement {
    effect = "Allow"
    actions = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.config_bucket.arn]
  }
}

resource "aws_iam_role_policy" "config_s3_delivery_policy" {
    name = "guardrail-config-s3-delivery"
    role = aws_iam_role.config_Role.id
    policy = data.aws_iam_policy_document.config_s3_delivery.json
  
}

resource "aws_config_configuration_recorder" "this" {
    name = default
    role_arn = aws_iam_role.config_Role.arn
  
    recording_group {
      all_supported = true
      include_global_resource_types = true
    }
  
}

resource "aws_config_delivery_channel" "this" {
    name = "guardrail-config-delivery-channel"
    s3_bucket_name = aws_s3_bucket.config_bucket.bucket
  
    depends_on = [aws_config_configuration_recorder.this]
  
}

resource "aws_config_configuration_recorder_status" "this" {
    name = aws_config_configuration_recorder.this.name
    is_enabled = true
  
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
    name = "s3-bucket-public-read-prohibited"
    source {
      owner = "AWS"
      source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    }
  depends_on = [ aws_config_configuration_recorder.this ]
}

resource "aws_config_config_rule" "restricted_ssh" {
    name = "restricted-ssh"
    source {
        owner = "AWS"
        source_identifier = "INCOMING_SSH_DISABLED"
    }
    depends_on = [ aws_config_configuration_recorder.this ]
  
}

resource "aws_config_config_rule" "iam_user_mfa_enabled" {
    name = "iam-user-mfa-enabled"
    source {
        owner = "AWS"
        source_identifier = "IAM_USER_MFA_ENABLED"
    }
    depends_on = [ aws_config_configuration_recorder.this ]
  
}