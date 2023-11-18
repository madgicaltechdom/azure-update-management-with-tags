
# Automated Azure Patching with Maintenance Configuration

This script automates the patching of virtual machines using Azure Maintenance Configuration. It creates a maintenance configuration schedule, retrieves the maintenance configuration ID, prompts the user for virtual machine names, and adds the virtual machines to the maintenance configuration.

### Prerequisites

* Azure PowerShell 2.7 or later
* Azure RM cmdlets installed
* An Azure subscription with the following permissions

### File 1: Configuration Parameters (config.ps1)

This file defines various configuration parameters required for setting up the maintenance configuration schedule. Here are some of the notable parameters:

    $RGName: Resource Group name.
    $configName: Configuration name.
    $scope: Maintenance scope, set to "InGuestPatch."
    $location: Azure region where the maintenance will occur (e.g., "centralindia").
    $startDateTime: Start date and time for the maintenance window.
    $timeZone: Time zone for the maintenance window (e.g., "India Standard Time").
    $duration: Duration of the maintenance window (e.g., "01:30").
    $recurEvery: Recurrence frequency (e.g., "1Day").
    $RebootOption: Reboot option, set to "IfRequired."
    $WindowsParameterClassificationToInclude: Windows update classifications to include.
    $LinuxParameterClassificationToInclude: Linux update classifications to include.

### File 2: Maintenance Configuration Script (main.ps1)

The script follows these key steps:

* Import Modules: Imports Azure PowerShell modules (Az, Az.Compute, Az.Maintenance).

* Load Configuration: Loads configuration parameters from config.ps1.

* Create Maintenance Configuration: Uses the configuration parameters to create a maintenance configuration schedule.

* Retrieve Configuration ID: Retrieves the ID of the newly created maintenance configuration.

* Input Virtual Machine Names: Prompts the user to input virtual machine names separated by commas.

* Assign Virtual Machines: Loops through the virtual machine names, creating configuration assignments for each in the specified maintenance configuration.

### Usage Instructions:

* Ensure that Azure PowerShell modules are installed.
* Set up the configuration parameters in config.ps1.
* Run maint.ps1 to create and assign maintenance configurations for specified virtual machines.

### Note: 
Make sure to review and customize the configuration parameters based on your specific requirements before running the scripts.


