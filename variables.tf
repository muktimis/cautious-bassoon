variable "enable_guardduty" {
  type    = bool
  default = true
}

variable "finding_publishing_frequency" {
  type    = string
  default = "FIFTEEN_MINUTES"
}

variable "aws_region" {
  type    = string
  default = "ca-central-1"
}