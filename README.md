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
* [Complete video of task overview](https://drive.google.com/file/d/1hDAksoPiYcBi1CbYkya_6vfVE7JtReNS/view?usp=sharing)
* You can watch below video for more information.
* [Part 1](https://drive.google.com/file/d/1_LWuTWXkLA21Bk2e-YKJpgAR87jHiSWL/view?usp=drive_link)
* [Part 2](https://drive.google.com/file/d/11mwDKzV1c6es51LrriejnGJHlLS4fIZ2/view?usp=drive_link)
* [Part 3](https://drive.google.com/file/d/1O9vMRh89NmIdn5uil79DEMeWYUHCoeQj/view?usp=sharing)
* [How to Connect VM to Azure Log Analytics](https://drive.google.com/file/d/1baXUXuJYfSgnZhPpdu72rRsvX4XC9QeE/view?usp=sharing)


```bash



# Clone the repo with following command

$ git clone https://github.com/madgicaltechdom/azure-update-management-with-tags.git

...
#Then run bicep file to deploye

$ cd azure-update-management-with-tags/bicep

...

# Then login to azure portal and create the Resource Group

$ az login

```
* Step 1: Open code in VS editor and Changing Time Zone
  Use the PowerShell script provided at this link: UM-ScheduleUpdatesWithVmsTags.ps1 to change the timezone for your machines. This would be our repository(we would make that public)
  
* Step 2: Adding Tag Policy Update
  Update the tag policy as specified in the main.bicep file.
  **Note**: In policy tag keep your patch time more than 20 minutes after at the current time.

* Step 3: Running the Bicep Script using below command.
  Run the Bicep script to apply the changes to your Azure environment.
  Wait for the resources to be generated.

* Deploy **without email feature**:
```bash
$ az deployment group create --resource-group your-resource-group-name --template-file main.bicep
```

Infrastructure deployment will take around 5 minutes and it can take until 20 minutes to have update agent ready and first patching assessment. 


* Step 4: Goto azure portal and Open Automation Account
  Navigate to the Azure Automation Account that you created.
  Assign *Contributor* role on the System-assigned Managed Identity to the Resource Group.
  Show the Jobs section to demonstrate scheduled tasks.

* After assigning the role, goto runbooks tab in left menu of (same automation account as above) automation account. You got all 
  your runbooks. Click on the UM-ScheduleUpdatesWithVmsTags runbook then start it and wait for it run successfully.

* Then back to your automation account. Go to schedule tab in left menu and click you got your all schedules.

**Note:** 
If your schedule time or date are incorrect then simply go to automation account and then got to schedule tab in left menu you will see your all scheduled tasks if schedule time or date are incorrect then simply click on schedule then a modal is open here you can reschedule your time and date accordingly and save then wait for your schedule time. It works fine. 
Now wait for schedule time.

* Step 5: At your schedule go to your automation account and click on job tab in left menu. Here you will see your all job which is    
  you schedule. Now wait to complete your jobs.

* Step 6: Snapshot After your schedule time.
  Wait for your schedule time and successfully completion of task.

* Step 7: Open Automation Account (Again)
  Return to the Automation Account.
  Show the Jobs section again to demonstrate patch management tasks along with Pre and Post tasks.

* Step 8: Open the Solution (poc-updatemanagement - Again)
  Go back to the "poc-updatemanagement" solution.
  Show the updated summary of current patch management to demonstrate that it's working as expected.

* Conclusion:
    In this video, we've successfully set up and demonstrated Azure Update Management for Windows and Ubuntu Machines. This ensures that your systems are up-to-date and secure.

## If you want to enable patching report email feature later, just update SendGridSender and SendGridAPIKey Automation Account variables.

* You can simply go to main.bicep file and the update below lines:
  ```ruby
    param SendGridAPIKey string = 'your send grig key'
    param SendGridSender string = 'your sender email address'
  ```

* Update the update-tags, include receiver email address here as below:
  ```ruby
    tags_policy_update: 'Wednesday;10:20 AM;Always;*java*,*oracle*;demo.receiver@gmail.com'
  
  ```

* run the following command:
  $ az deployment group create --resource-group MyRg --template-file main.bicep --parameters SendGridSender="no-reply@mydomain.fr" SendGridAPIKey="SG.XXXXXXXXXXXXX-XXXXXXXXXXXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX"

**Note:**
* If your runbook giving error and not run successfully then goto you automation account and left menu tab select variables.
* Here you change your send grid api key and email with the help of edit.
* Then restart your runbook again and goto schedules and schedule your vm according to your time.

This run succesfully and you will recieve the notifications email.



# Output images
![vm-machines](https://github.com/madgicaltechdom/azure-update-management-with-tags/assets/91054127/fe26c4b1-3208-4046-9788-6df50195dee7)
![vm-runbook](https://github.com/madgicaltechdom/azure-update-management-with-tags/assets/91054127/78c3df0c-5b02-44c5-8b26-2e8d77d447c9)


## how to use Azure Update Manager to schedule updates on Virtual Machines 
Log in to Azure: Access your Azure portal at portal.azure.com.

Navigate to Update Manager: In the Azure portal, search for "Update Manager" and click on it.

Create an Update Deployment: Click "Schedule update deployment" to create a new update schedule.

Define Schedule: Choose your preferred schedule for updates, like daily or weekly.

Select VMs: Pick the virtual machines that need updates.

Review Settings: Confirm your settings and click "Create" to schedule the deployment.

Monitor Progress: Go back to "Update Manager" to check the deployment's progress.

Review Status: Once the updates are applied, review the status to ensure they were successful.

You can watch the below video for more information.
Video link: 


