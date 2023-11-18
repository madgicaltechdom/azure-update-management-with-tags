Import-Module Az
Import-Module Az.Compute
Import-Module Az.Maintenance

#Load the configuration file
. "$PSScriptRoot\config.ps1"


# Create a maintenance configuration schedule
$config = New-AzMaintenanceConfiguration -ResourceGroupName $RGName -Name $configName -MaintenanceScope $scope -Location $location -StartDateTime $startDateTime -TimeZone $timeZone -Duration $duration -RecurEvery $recurEvery -WindowParameterClassificationToInclude $WindowsParameterClassificationToInclude -WindowParameterKbNumberToInclude $WindowParameterKbNumberToInclude -WindowParameterKbNumberToExclude $WindowParameterKbNumberToExclude -InstallPatchRebootSetting $RebootOption -LinuxParameterPackageNameMaskToInclude $LinuxParameterPackageNameMaskToInclude -LinuxParameterClassificationToInclude $LinuxParameterClassificationToInclude -LinuxParameterPackageNameMaskToExclude $LinuxParameterPackageNameMaskToExclude -ExtensionProperty @{"InGuestPatchMode"="User"}

# Retrieve the maintenance configuration ID
$configId = $config.Id

# Now $configId contains the ID of the newly created maintenance configuration
Write-Host "Maintenance Configuration ID: $configId"


# Get virtual machine names from user input
$VMNames = Read-Host -Prompt "Enter virtual-machine names (separated by commas)"

# Split the input string into an array of VM names
$VMArray = $VMNames -split ',' | ForEach-Object { $_.Trim() }

# Loop through each virtual machine name and add it to the maintenance configuration
foreach ($VMName in $VMArray) {
    # Set the virtual machine name
    $assignVMs = New-AzConfigurationAssignment -ResourceGroupName $RGName -Location $location -ResourceName $VMName -ResourceType "VirtualMachines" -ProviderName "Microsoft.Compute" -ConfigurationAssignmentName $configName -MaintenanceConfigurationId $configId
}


Write-Host "Added virtual machines to the maintenance configuration."


