###############################################################################
# Security Hub — aggregates findings from Config, GuardDuty, IAM Access
# Analyzer, etc into one prioritized dashboard. This is the single pane of
# glass; Week 2's Lambdas subscribe to its findings via EventBridge.
###############################################################################

resource "aws_securityhub_account" "this" {}

# CIS AWS Foundations Benchmark — the most widely recognized baseline.
# Good to lead with in client conversations: "I measure against CIS."
resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/cis-aws-foundations-benchmark/v/1.2.0"

  depends_on = [aws_securityhub_account.this]
}

# AWS Foundational Security Best Practices — broader coverage than CIS alone.
resource "aws_securityhub_standards_subscription" "fsbp" {
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [aws_securityhub_account.this]
}

# Wire GuardDuty findings into Security Hub explicitly.
resource "aws_securityhub_product_subscription" "guardduty" {
  count       = var.enable_guardduty ? 1 : 0
  product_arn = "arn:aws:securityhub:${var.aws_region}::product/aws/guardduty"

  depends_on = [aws_securityhub_account.this, aws_guardduty_detector.this]
}
