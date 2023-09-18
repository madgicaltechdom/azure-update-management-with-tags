Azure VM Patching Automation with Terraform
===========================================

This repository contains Terraform code to set up scheduled patching for Azure Virtual Machines using Azure Automation. Before you begin, make sure you have an existing Azure Resource Group and Automation Account that you want to use for this automation. You will need to import these resources into Terraform.

Prerequisites
-------------

Before you get started, ensure you have the following prerequisites:

1.  **Azure CLI**: Install the Azure CLI by following the instructions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
    
2.  **Terraform**: Install Terraform by following the instructions [here](https://learn.hashicorp.com/tutorials/terraform/install-cli).
    
3.  **Azure Resource Group and Automation Account**: You should have an existing Azure Resource Group and Automation Account. If not, create them using the Azure Portal or Azure CLI. The Automation account must use a System-assigned Managed Identity and The System-assigned Managed Identity must have Contributor role.
    

Import Existing Resources
-------------------------

Before applying the Terraform configuration, you need to import your existing Azure Resource Group and Automation Account into Terraform. Run the following commands:


### Initialize Terraform
```
terraform init
``` 
### Import Resource Group
```
terraform import azurerm_resource_group.baseInfraUM_rg /subscriptions/<subscription_id>/resourceGroups/<resource_group_name>
```
### Import Automation Account
```
terraform import azurerm_automation_account.automationAccount /subscriptions/<subscription_id>/resourceGroups/<resource_group_name>/providers/Microsoft.Automation/automationAccounts/<automation_account_name>

```

Replace `<subscription_id>`, `<resource_group_name>`, and `<automation_account_name>` with your specific values.

Configure Virtual Machines With POLICY_UPDTAE Tag
-----------------------------

Here is the syntax to follow for the `POLICY_UPDATE` tag:

[![POLICY_UPDATE Syntax](docs/tag_syntax.png)](docs/tag_syntax.png)

**Examples**:

*   VM1 - `POLICY_UPDATE=Friday;10:00 PM;Never;*java*;` will be patched every Friday, at 10:00 PM. Even if updates require reboot, the VM will not be rebooted. Packages containing `java` string will be excluded.
*   VM2 - `POLICY_UPDATE=Tuesday,Sunday;08:00 AM;IfRequired;;TeamA@abc.com` will be patched every Tuesday and Sunday, at 08:00 AM. The VM will be rebooted only if a patch needs the machine to be reboot to be taken into account. No excluded packages. When patching is done, [TeamA@abc.com](mailto:TeamA@abc.com) will receive the list of updated packages by mail.
*   VM3 - `POLICY_UPDATE=Sunday;07:00 PM;Always;;` will be patched every Synday at 07:00 PM. The VM will be rebooted after applying patches, even if it is not required. No excluded packages.
*   VM4 - `POLICY_UPDATE=Monday;01:00 PM;Always;*java*,*oracle*;TeamB@abc.com` will be patched every Monday at 01:00 PM. The VM will be rebooted after applying patches. Packages containing `java` or `oracle` string will be excluded. When patching is done, [TeamB@abc.com](mailto:TeamB@abc.com) will receive the list of updated packages by mail.

Deploy the Patching Automation
------------------------------

Now that you have imported your existing resources and configured the patch schedule, you can deploy the patching automation using Terraform.

1.  Run the following command to plan the deployment and ensure there are no errors:
    
    shellCopy code
    
    `terraform plan`
    
2.  If the plan looks good, apply the Terraform configuration:
    
    shellCopy code
    
    `terraform apply`
    
3.  Confirm the changes by typing `yes` when prompted.
    

Terraform will now deploy the necessary resources and configure the patching schedule for your Azure Virtual Machines.

Destroy the Patching Automation
-------------------------------

If you ever need to tear down the patching automation, you can use Terraform to destroy the resources:

shellCopy code

`terraform destroy`

Additional Resources
--------------------

For more information on Terraform, Azure Automation, or cron schedules, refer to the following resources:

*   [Terraform Documentation](https://www.terraform.io/docs/index.html)
*   [Azure Automation Documentation](https://docs.microsoft.com/en-us/azure/automation/)
*   [Azure Automation Update Management](https://docs.microsoft.com/en-us/azure/automation/update-management/overview)
*   [Cron Expression Syntax](https://en.wikipedia.org/wiki/Cron#Overview)

Please feel free to contribute to this repository, report issues, or provide feedback. Happy patching!
