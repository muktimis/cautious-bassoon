output "config_recorder_name" {
  description = "Name of the AWS Config recorder — referenced when wiring EventBridge rules in Week 2."
  value       = aws_config_configuration_recorder.this.name
}

output "config_bucket_name" {
  description = "S3 bucket storing Config history."
  value       = aws_s3_bucket.config_bucket.bucket
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID — needed for any custom finding filters later."
  value       = var.enable_guardduty ? aws_guardduty_detector.this[0].id : null
}

output "security_hub_account_id" {
  description = "Confirms Security Hub is enabled in this account."
  value       = aws_securityhub_account.this.id
}

output "account_id" {
  description = "AWS account ID this stack was deployed into."
  value       = data.aws_caller_identity.current.account_id
}
