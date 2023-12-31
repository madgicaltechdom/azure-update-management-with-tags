
provider "azurerm" {
  features {}

}

# Deploy demo resource group
resource "azurerm_resource_group" "baseInfraUM_rg" {
  name     = var.resource_group_name
  location = "centralindia"
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Deploy automation account
resource "azurerm_automation_account" "automationAccount" {
  name                = var.automation_account_name
  location            = azurerm_resource_group.baseInfraUM_rg.location
  resource_group_name = azurerm_resource_group.baseInfraUM_rg.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

}

# Set variable for send grid api key
resource "azurerm_automation_variable_string" "sendgrid_api_key" {
  name                    = "SendGridAPIKey"
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  value                   = var.sendgrid_api_key
}

# Set variable for sender email
resource "azurerm_automation_variable_string" "sender_email" {
  name                    = "SendGridSender"
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  value                   = var.sender_email
}

# Deploy log analytics workspace
resource "azurerm_log_analytics_workspace" "log_anaytics_workspace" {
  name                = var.log_analytics_workspace
  location            = azurerm_resource_group.baseInfraUM_rg.location
  resource_group_name = azurerm_resource_group.baseInfraUM_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Link the automation account to the log analytics workspace
resource "azurerm_log_analytics_linked_service" "link_law_automation" {
  resource_group_name = azurerm_resource_group.baseInfraUM_rg.name
  workspace_id        = azurerm_log_analytics_workspace.log_anaytics_workspace.id
  read_access_id      = azurerm_automation_account.automationAccount.id
}

# Install Update Management solution on Log Analytics Workspace
resource "azurerm_log_analytics_solution" "automation_account_solutions_updates" {
  solution_name         = "Updates"
  location              = azurerm_resource_group.baseInfraUM_rg.location
  resource_group_name   = azurerm_resource_group.baseInfraUM_rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.log_anaytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_anaytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}

# Add Az.Account module to Automation Account
resource "azurerm_automation_module" "automation_account_module_accounts" {
  name                    = "Az.Accounts"
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/az.accounts/2.10.3"
  }
}

# Add Az.ResourceGraph module to Automation Account
resource "azurerm_automation_module" "automation_account_module_resourcegraph" {
  name                    = "Az.ResourceGraph"
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/az.resourcegraph/0.13.0"
  }
  depends_on = [azurerm_automation_module.automation_account_module_accounts]
}

# (Optional: for Azure Arc for Servers) Add Az.ConnectedMachine module to Automation Account
resource "azurerm_automation_module" "automation_account_module_connectedmachine" {
  name                    = "Az.ConnectedMachine"
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/az.connectedmachine/0.2.0"
  }
  depends_on = [azurerm_automation_module.automation_account_module_accounts]
}

# Deploy Automation Account Runbook - UM-ScheduleUpdatesWithVmsTags
resource "azurerm_automation_runbook" "UM-ScheduleUpdatesWithVmsTags" {
  name                    = "UM-ScheduleUpdatesWithVmsTags"
  location                = azurerm_resource_group.baseInfraUM_rg.location
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  log_verbose             = "false"
  log_progress            = "true"
  description             = "Updatemanagement-schedule updates VMs with tags Runbook"
  runbook_type            = "PowerShell"
  publish_content_link {
    uri = "https://raw.githubusercontent.com/madgicaltechdom/azure-update-management-with-tags/main/runbooks/UM-ScheduleUpdatesWithVmsTags.ps1"
  }
}

# Deploy Automation Account Runbook - UM-PreTasks
resource "azurerm_automation_runbook" "UM-PreTasks" {
  name                    = "UM-PreTasks"
  location                = azurerm_resource_group.baseInfraUM_rg.location
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  log_verbose             = "false"
  log_progress            = "true"
  description             = "Updatemanagement-pretask Runbook"
  runbook_type            = "PowerShell"
  publish_content_link {
    uri = "https://raw.githubusercontent.com/madgicaltechdom/azure-update-management-with-tags/main/runbooks/UM-PreTasks.ps1"
  }
}

# Deploy Automation Account Runbook - UM-PostTasks 
resource "azurerm_automation_runbook" "UM-PostTasks" {
  name                    = "UM-PostTasks"
  location                = azurerm_resource_group.baseInfraUM_rg.location
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  log_verbose             = "false"
  log_progress            = "true"
  description             = "Updatemanagement-post task Runbook"
  runbook_type            = "PowerShell"
  publish_content_link {
    uri = "https://raw.githubusercontent.com/madgicaltechdom/azure-update-management-with-tags/main/runbooks/UM-PostTasks.ps1"
  }
}

# Deploy Automation Account Runbook - UM-CleanUp-Schedules
resource "azurerm_automation_runbook" "UM-CleanUp-Schedules" {
  name                    = "UM-CleanUp-Schedules"
  location                = azurerm_resource_group.baseInfraUM_rg.location
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  log_verbose             = "false"
  log_progress            = "true"
  description             = "Updatemanagement-CleanUpSchedules Runbook"
  runbook_type            = "PowerShell"
  publish_content_link {
    uri = "https://raw.githubusercontent.com/madgicaltechdom/azure-update-management-with-tags/main/runbooks/UM-CleanUp-Schedules.ps1"
  }
}

# Deploy Automation Account Runbook - UM-CleanUp-Snapshots
resource "azurerm_automation_runbook" "UM-CleanUp-Snapshots" {
  name                    = "UM-CleanUp-Snapshots"
  location                = azurerm_resource_group.baseInfraUM_rg.location
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  log_verbose             = "false"
  log_progress            = "true"
  description             = "Updatemanagement-CleanUpSnapshots Runbook"
  runbook_type            = "PowerShell"
  publish_content_link {
    uri = "https://raw.githubusercontent.com/madgicaltechdom/azure-update-management-with-tags/main/runbooks/UM-CleanUp-Snapshots.ps1"
  }
}

# Create daily schedule - will be used by runbooks
resource "azurerm_automation_schedule" "UM-Schedule-daily" {
  name                    = "UM-Schedule-daily"
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  frequency               = "Day"
  interval                = 1
  timezone                = "Asia/Kolkata"
  #timezone                = "Australia/Perth"
  #start_time              = "2014-04-15T18:00:15+02:00"
  description = "Schedule daily"
  #week_days               = ["Friday"]
}

# Schedule "UM-ScheduleUpdatesWithVmsTags" Runbook with "UM-Schedule-daily" schedule
resource "azurerm_automation_job_schedule" "UM-ScheduleRunbook-ScheduleUpdatesWithVmsTags" {
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  schedule_name           = azurerm_automation_schedule.UM-Schedule-daily.name
  runbook_name            = azurerm_automation_runbook.UM-ScheduleUpdatesWithVmsTags.name
}

# Schedule "UM-CleanUp-Schedules" Runbook with "UM-Schedule-daily" schedule
resource "azurerm_automation_job_schedule" "UM-CleanUp-Schedules" {
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  schedule_name           = azurerm_automation_schedule.UM-Schedule-daily.name
  runbook_name            = azurerm_automation_runbook.UM-CleanUp-Schedules.name
}

# Schedule "UM-CleanUp-Snapshots" Runbook with "UM-Schedule-daily" schedule
resource "azurerm_automation_job_schedule" "UM-CleanUp-Snapshots" {
  resource_group_name     = azurerm_resource_group.baseInfraUM_rg.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  schedule_name           = azurerm_automation_schedule.UM-Schedule-daily.name
  runbook_name            = azurerm_automation_runbook.UM-CleanUp-Snapshots.name
}