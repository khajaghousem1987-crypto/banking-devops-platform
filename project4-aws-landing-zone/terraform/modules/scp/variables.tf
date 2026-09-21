variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = ""
}

variable "policy_content" {
  type = string
}

variable "target_ids" {
  type = list(string)
}