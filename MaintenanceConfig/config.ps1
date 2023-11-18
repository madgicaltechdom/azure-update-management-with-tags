# config.ps1

$RGName = "training-update"
$configName = "azurepatch5110"
$scope = "InGuestPatch"
$location = "centralindia"
$startDateTime = "2023-11-17 16:58"
$timeZone = "India Standard Time"
$duration = "01:30"
$recurEvery = "1Day"
$RebootOption = "IfRequired"
$WindowsParameterClassificationToInclude = "Critical","Security","FeaturePack","ServicePack","Definition","Tools","Updates"
$WindowParameterKbNumberToInclude = $null
$WindowParameterKbNumberToExclude = $null
$LinuxParameterClassificationToInclude = "Other","Critical","Security"
$LinuxParameterPackageNameMaskToInclude = $null
$LinuxParameterPackageNameMaskToExclude = $null

