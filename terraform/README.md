Azure VM Patching Automation with Terraform
===========================================

This repository contains Terraform code to set up scheduled patching for Azure Virtual Machines using Azure Automation. Before you begin, make sure you have an existing Azure Resource Group and Automation Account that you want to use for this automation. You will need to import these resources into Terraform.

Prerequisites
-------------

Before you get started, ensure you have the following prerequisites:

1.  **Azure CLI**: Install the Azure CLI by following the instructions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli). You should run `az login` and authenticate your user.
    
2.  **Terraform**: Install Terraform by following the instructions [here](https://learn.hashicorp.com/tutorials/terraform/install-cli).
    
3.  **Azure Resource Group and Automation Account**: You should have an existing Azure Resource Group and Automation Account. If not, create them using the Azure Portal or Azure CLI. The Automation account must use a System-assigned Managed Identity and The System-assigned Managed Identity must have Contributor role.
    
### How to get started
```
git clone https://github.com/madgicaltechdom/azure-update-management-with-tags.git
cd azure-update-management-with-tags/terraform
```
-------------------------

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

### Note: If you need to remove terraform state 

First, you need to identify the resource you want to remove. You can do this by running the terraform state list command, which will list all the resources in your current state.

```
terraform state list

```
Once you’ve identified the resource, you can remove it using the terraform state rm command followed by the resource address.

```
terraform state rm <resource_address>

```
After removing the resource, verify it by running the terraform state list command again. The removed resource should no longer appear in the list.

```
terraform state list

```

Configure Virtual Machines With POLICY_UPDTAE Tag
-----------------------------
You need to add `POLICY_UPDATE` to your existing Virtual Machines. 

Here is the syntax to follow for the `POLICY_UPDATE` tag:

![POLICY_UPDATE Syntax](https://raw.githubusercontent.com/madgicaltechdom/azure-update-management-with-tags/main/docs/tag_syntax.png)

**Examples**:

*   VM1 - `POLICY_UPDATE=Friday;10:00 PM;Never;*java*;` will be patched every Friday, at 10:00 PM. Even if updates require reboot, the VM will not be rebooted. Packages containing `java` string will be excluded.
*   VM2 - `POLICY_UPDATE=Tuesday,Sunday;08:00 AM;IfRequired;;TeamA@abc.com` will be patched every Tuesday and Sunday, at 08:00 AM. The VM will be rebooted only if a patch needs the machine to be reboot to be taken into account. No excluded packages. When patching is done, [TeamA@abc.com](mailto:TeamA@abc.com) will receive the list of updated packages by mail.
*   VM3 - `POLICY_UPDATE=Sunday;07:00 PM;Always;;` will be patched every Synday at 07:00 PM. The VM will be rebooted after applying patches, even if it is not required. No excluded packages.
*   VM4 - `POLICY_UPDATE=Monday;01:00 PM;Always;*java*,*oracle*;TeamB@abc.com` will be patched every Monday at 01:00 PM. The VM will be rebooted after applying patches. Packages containing `java` or `oracle` string will be excluded. When patching is done, [TeamB@abc.com](mailto:TeamB@abc.com) will receive the list of updated packages by mail.

Deploy the Patching Automation
------------------------------

Now that you have imported your existing resources and configured the patch schedule, you can deploy the patching automation using Terraform.

1.  Run the following command to plan the deployment and ensure there are no errors:
    
    ```terraform plan```
    
2.  If the plan looks good, apply the Terraform configuration:
    
    
    ```terraform apply```
    
3.  Confirm the changes by typing `yes` when prompted.
    

Terraform will now deploy the necessary resources and configure the patching schedule for your Azure Virtual Machines.

Steps To Add Virtual Machines to Log Analytics WorkSpace
-----

### 1\. Sign In to Azure Portal

1.  Go to the [Azure portal](https://portal.azure.com/) and sign in with your Azure account.

### 2\. Navigate to Log Analytics Workspace

1.  In the Azure portal, click on "Resource groups" in the left-hand menu.
    
2.  Select the resource group where your Log Analytics workspace is located.
    
3.  In the resource group, click on your Log Analytics workspace to open it.
    

### 3\. Configure Data Collection

1.  In the Log Analytics workspace, click on "Data" under the "Settings" section in the left-hand menu.
    
2.  Click on "Virtual Machines" under "Collect data."
    

### 4\. Add Virtual Machines

1.  Click on the "Add" button to start adding virtual machines.
    
2.  In the "Configuration" tab:
    
    *   Select the target Log Analytics workspace from the dropdown.
    *   Choose the desired data types to collect. This could include system and custom logs.
3.  In the "Virtual Machines" tab:
    
    *   Select the Azure Virtual Machines that you want to enable for log forwarding. You can select multiple VMs.
4.  Click the "Add" button to confirm your selection.
    

### 5\. Save Configuration

1.  Review your configuration settings to ensure they are accurate.
    
2.  Click the "Save" button to save the configuration.

Destroy the Patching Automation
-------------------------------

If you ever need to tear down the patching automation, you can use Terraform to destroy the resources:

```terraform destroy```

### Reference Videos

For detailed instructions and visual guidance, you can refer to the following reference videos:

1.  [Installation and configuration on VM machines](https://drive.google.com/file/d/1yQm4fBcdNkwuZebzfSwGhzFiAev7kZ0D/view): (A complete instructions to run the terraform script and configure existing VM for patch management)
    
2.  [Verification](https://drive.google.com/file/d/1nXdNy88Sq_Kp0Hey-BKtwrZX0kbaYqHf/view?usp=drive_link): (Shows the result of the scheduler, and the snapshot of the machine and summary of the Updates(rezoanalytics) )


### If you want to enable patching report email feature later, just update SendGridSender and SendGridAPIKey Automation Account variables.

* Make sure pulled the latest code from the github repository.

* Then you can simply go to variables.tf file and the update below lines:
  ```ruby
        # Define the variable for the send grid api key
        variable "sendgrid_api_key" {
        description = "Name of the send grid api key"
        type        = string
        default     = "your send grid api key"
        }

        # Define the variable for the sender email address
        variable "sender_email" {
        description = "Name of the sender email address"
        type        = string
        default     = "your sender email address"
        }
  ```
* Follow the same instructions as above mentioned for run terraform script.

**Note:**
* If your runbook giving error and not run successfully then goto you automation account and left menu tab select variables.
* Here you change your send grid api key and email with the help of edit.
* Then restart your runbook again and goto schedules and schedule your vm according to your time.

This run succesfully and you will recieve the notifications email.

Additional Resources
--------------------

For more information on Terraform, Azure Automation, or cron schedules, refer to the following resources:

*   [Terraform Documentation](https://www.terraform.io/docs/index.html)
*   [Azure Automation Documentation](https://docs.microsoft.com/en-us/azure/automation/)
*   [Azure Automation Update Management](https://docs.microsoft.com/en-us/azure/automation/update-management/overview)
*   [Cron Expression Syntax](https://en.wikipedia.org/wiki/Cron#Overview)

Please feel free to contribute to this repository, report issues, or provide feedback. Happy patching!
