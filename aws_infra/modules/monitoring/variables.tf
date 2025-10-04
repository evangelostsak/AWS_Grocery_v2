variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "common_tags" {
  description = "Additional user-specified tags to merge with enforced tags"
  type        = map(string)
  default     = {}
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group whose metrics are monitored"
  type        = string
}

variable "alert_email" {
  description = "Email address subscribed to the SNS alerts topic"
  type        = string
}

variable "cpu_threshold" {
  description = "Average CPU utilization (%) threshold to trigger alarm"
  type        = number
  default     = 80
}

variable "cpu_period" {
  description = "Evaluation period (seconds) for CPU metric"
  type        = number
  default     = 300
}

variable "disk_threshold" {
  description = "Disk usage percent threshold to trigger alarm"
  type        = number
  default     = 80
}

variable "disk_period" {
  description = "Evaluation period (seconds) for disk usage metric"
  type        = number
  default     = 300
}

variable "disk_filesystem" {
  description = "Filesystem device name reported by CloudWatch Agent"
  type        = string
  default     = "/dev/xvda1"
}

variable "disk_mount_path" {
  description = "Mount path corresponding to the monitored filesystem"
  type        = string
  default     = "/"
}

