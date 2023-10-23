# Define the variable for the Automation Account name
variable "automation_account_name" {
  description = "Name of the existing Azure Automation Account"
  type        = string
  default     = "automationaccount03"
}

# Define the variable for the Resource Group name
variable "resource_group_name" {
  description = "Name of the existing Azure Resource Group"
  type        = string
  default     = "training-update"
}

# Define the variable for the Log Analytics WorkSpace
variable "log_analytics_workspace" {
  description = "Name of the Log Analytics WorkSpace"
  type        = string
  default     = "rezoanalytics"
}

# Define the variable for the send grid api key
variable "sendgrid_api_key" {
  description = "Name of the send grid api key"
  type        = string
  default     = ""
}

# Define the variable for the sender email address
variable "sender_email" {
  description = "Name of the sender email address"
  type        = string
  default     = ""
}