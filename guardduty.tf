###############################################################################
# GuardDuty — continuous threat detection (unusual API calls, compromised
# credentials, crypto-mining, port scanning, etc). Feeds into Security Hub.
###############################################################################

resource "aws_guardduty_detector" "this" {
  count  = var.enable_guardduty ? 1 : 0
  enable = true

  finding_publishing_frequency = var.finding_publishing_frequency

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }
}