# Define the variable for the Automation Account name
variable "automation_account_name" {
  description = "Name of the existing Azure Automation Account"
  type        = string
  default = "automationAccount-03"
}

# Define the variable for the Resource Group name
variable "resource_group_name" {
  description = "Name of the existing Azure Resource Group"
  type        = string
  default = "training-update"
}

# Define the variable for the Log Analytics WorkSpace
variable "log_analytics_workspace" {
  description = "Name of the Log Analytics WorkSpace"
  type        = string
  default = "rezoanalytics"
}
