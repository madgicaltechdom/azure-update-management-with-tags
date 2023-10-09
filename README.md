# azure-vm-update-management-with-tags

This repo is a set of Runbooks that allows you to schedule Azure Virtual Machines patching (update-management) by simply applying the `POLICY_UPDATE` tag on machines.
Here is the syntax to follow for the POLICY_UPDATE tag:
Examples:
POLICY_UPDATE=Friday;10:00 PM;Never;*java*; will be patched every Friday, at 10:00 PM. Even if updates require reboot, the VM will not be rebooted. Packages containing java string will be excluded.

Runbooks description:
There is a set of 5 Runbooks that must be deployed in the Automation Account:
* **UM-ScheduleUpdatesWithVmsTags**: Must be scheduled (at least) daily. Searches for all machines with the `POLICY_UPDATE` tag and configures the Update Management schedules.
* **UM-PreTasks**: Triggered before patching, it can perform several optional actions like OS disk snapshot, start VM if stopped, etc..
* **UM-PostTasks**: Triggered after patching, it can perform several optional actions like stop VM if it was started, send patching report mail, etc..
* **UM-CleanUp-Snapshots**: Must be scheduled daily, to delete snapshots that are X days older.
* **UM-CleanUp-Schedules**: Must be schedule (at least) daily. It removes Update Management schedules for VM machines that not longer have the `POLICY_UPDATE` tag

## Prerequisites
  - [Create an Azure account](https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize?client_id=8e0e8db5-b713-4e91-98e6-470fed0aa4c2&response_type=code%20id_token&scope=openid%20profile&state=OpenIdConnect.AuthenticationProperties%3DCW8R5JHojzMLy-5y5Eo2FYZ9ykAOBMq7FTr_kzVCzk9RVzEJYYUP1TowtzLYYDstYRTumBD3DUJHPylZ9oRSj1qVVKlFXZz6YaWwa1S3E1RW3dZAknRhkUhmq-jgIQJFakxuxd6ZbZo1ijNd8IDIGG2MgsnnVwR_iGIKl18ioDnqEI0SQv6vdK6Yk1SOcnU0OehQ5-O73KvkMSs8pCzI5gz4WAjq3La-tWqs06Zi82G097Lwwf0Bxt9r6zTpbcQ_0V4eODU3rsjEx4m0GWDETg1ivRukWJIFm9R7OCG1Ko_TVLIzg_PGd2B5x8DMuQrpY9z9gA5oLY8hhZaRfIEbUOiav9Dri85uM_C6D0csvjhN63kA1yIaG2emsnGil8W0TIL3d1YZK4PRCHs2rr9I36TsOtPh3wZW1MzAHUJsZMlPLYLAh0jDHn6XXo03cRlSUZQZcD1_neXNVe5uP7Ayxmpc7yvG9bMde-WUWWMeaw4&response_mode=form_post&nonce=638301826653929237.MGI3MzZlZTktNjA3My00OWVmLWEyNWEtMDRlNjkzN2EzYmVjYzhkYWE5NGItNDg1ZC00ZGNhLWI0NTAtMzZmNmNkYmEwOGEx&redirect_uri=https%3A%2F%2Fsignup.azure.com%2Fapi%2Fuser%2Flogin&max_age=86400&post_logout_redirect_uri=https%3A%2F%2Fsignup.azure.com%2Fsignup%3Foffer%3Dms-azr-0044p%26appId%3D102%26ref%3D%26redirectURL%3Dhttps%3A%2F%2Fazure.microsoft.com%2Fget-started%2Fwelcome-to-azure%2F%26l%3Den-in%26srcurl%3Dhttps%3A%2F%2Fazure.microsoft.com%2Ffree&x-client-SKU=ID_NET472&x-client-ver=6.30.1.0)
  - [install Azure cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
  - [install bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#install-manually)

Automation Account must have the following modules installed:
* Az.ResourceGraph, >= 0.11.0
* Az.ConnectedMachine >= 0.2.0
* Az.Automation >= 1.7.1
* Az.Compute >= 4.17.1

**Note**: Runbooks must be deployed using Powershell Runtime v5.1 
          Assign *Contributor* role on the System-assigned Managed Identity to the Resource Group
# Getting started

## Quick deployment (for testing purpose)

To quickly test provided Runbooks, use the provided bicep script to deploy a complete testing infrastructure that will: 
* Deploy a Log Analytics Workspace
* Deploy an Automation Account using a System-assigned Magaged Identity
  * Install Update Management solution
  * Assign *Contributor* role on the System-assigned Managed Identity to the Resource Group
  * [Video](https://drive.google.com/file/d/1Mo7nq79shmxYFsTVR6e06zJSneG-q2CT/view?usp=drive_link)
* Deploy 5 Runbooks to the Automation Accounts and schedule few of them
* Deploy 1 VNet
* Deploy 6 VMs (3 Windows, 3 Linux) in the VNet
  * with Log Analytics agent installed and plugged to the Log Analytics Workspace
  * with `POLICY_UPDATE` tag examples
* If you want to receive a **mail report**, 2 variables in the Automation Account needs to be defined : 
  * SendGridAPIKey (type: secure string): API access key provided by SendGrid to use your account
  * SendGridSender (type: string): Sender email address (from) configured on SendGrid

**Step-by-step user guide:**   
* [Part 1](https://drive.google.com/file/d/1_LWuTWXkLA21Bk2e-YKJpgAR87jHiSWL/view?usp=drive_link)
* [Part 2](https://drive.google.com/file/d/11mwDKzV1c6es51LrriejnGJHlLS4fIZ2/view?usp=drive_link)
* [Part 3](https://drive.google.com/file/d/1O9vMRh89NmIdn5uil79DEMeWYUHCoeQj/view?usp=sharing)

```bash

# Clone the repo with following command

$ git clone https://github.com/madgicaltechdom/azure-update-management-with-tags.git

...
#Then run bicep file to deploye

$ cd azure-update-management-with-tags/bicep
```

* Deploy **without email feature**:
```bash
$ az deployment group create --resource-group your-resource-group-name --template-file main.bicep
```

Infrastructure deployment will take around 5 minutes and it can take until 20 minutes to have update agent ready and first patching assessment. 


**Quick start:**

Azure Update Management for Windows and Ubuntu Machines. We'll cover the following tasks:

* Step 1: Login to azure portal and create the Resource Group

* Step 2: Open code in VS editor and Changing Time Zone
  Use the PowerShell script provided at this link: UM-ScheduleUpdatesWithVmsTags.ps1 to change the timezone for your machines. This would be our repository(we would make that public)

* Step 3: Adding Tag Policy Update
  Update the tag policy as specified in the main.bicep file.
  **Note**: In policy tag keep your patch time more than 20 minutes after at the current time.

* Step 4: Running the Bicep Script
  Run the Bicep script to apply the changes to your Azure environment.
  Wait for the resources to be generated.

* Step 5: Goto azure portal and Open Automation Account
  Navigate to the Azure Automation Account that you created.
  Assign *Contributor* role on the System-assigned Managed Identity to the Resource Group.
  Show the Jobs section to demonstrate scheduled tasks.

* Step 6: Open the Solution (poc-updatemanagement)
  Navigate to the "poc-updatemanagement" solution.
  Show the summary of the current patch management status.

* Step 7: Snapshot After your schedule time.
  Wait for your schedule time.
  After the specified time, show the snapshot of the machines mentioned in step 3.

* Step 8: Open Automation Account (Again)
  Return to the Automation Account.
  Show the Jobs section again to demonstrate patch management tasks along with Pre and Post tasks.

* Step 9: Open the Solution (poc-updatemanagement - Again)
  Go back to the "poc-updatemanagement" solution.
  Show the updated summary of current patch management to demonstrate that it's working as expected.

* Conclusion:
    In this video, we've successfully set up and demonstrated Azure Update Management for Windows and Ubuntu Machines. This ensures that your systems are up-to-date and secure.

**Note:** In case your machines are not schedule according to you tags because of permissions issues. Then you need assign permission to your resource group and then run runbook (UM-ScheduleUpdatesWithVmsTags) manually then your schedule worked fine.
If your schedule time or date are incorrect then simply go to automation account and then got to schedule tab in left menu you will see your all scheduled tasks if schedule time or date are incorrect then simply click on schedule then a modal is open here you can reschedule your time and date accordingly and save then wait for your schedule time. It works fine. 


# Output images
![vm-machines](https://github.com/madgicaltechdom/azure-update-management-with-tags/assets/91054127/fe26c4b1-3208-4046-9788-6df50195dee7)
![vm-runbook](https://github.com/madgicaltechdom/azure-update-management-with-tags/assets/91054127/78c3df0c-5b02-44c5-8b26-2e8d77d447c9)
