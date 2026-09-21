variable "project_name" {
  type = string
}

variable "limit_usd" {
  type = number
}

variable "notification_email" {
  type      = string
  default   = ""
  sensitive = true
}