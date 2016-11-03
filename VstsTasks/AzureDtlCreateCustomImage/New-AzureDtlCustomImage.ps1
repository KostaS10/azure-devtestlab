[CmdletBinding()]
Param(
    [string]$ConnectedServiceName,
    [string]$LabId,
    [string]$NewCustomImageName,
    [string]$Description,
    [string]$SourceLabVMId,
    [string]$OsType,
    [string]$LinuxOsState,
    [string]$WindowsOsState,
    [string]$OutputResourceId
)

Import-Module Microsoft.TeamFoundation.DistributedTask.Task.Common
Import-Module Microsoft.TeamFoundation.DistributedTask.Task.Internal

"Starting Azure DevTest Labs Create Custom Image Task"

"Task called with the following parameters:"
"  ConnectedServiceName = $ConnectedServiceName"
"  LabId = $LabId"
"  NewCustomImageName = $NewCustomImageName"
"  Description = $Description"
"  SourceLabVMId = $SourceLabVMId"
"  OsType = $OsType"
if ($OsType -eq 'Linux')
{
    "  LinuxOsState = $LinuxOsState"
}
elseif ($OsType -eq 'Windows')
{
    "  WindowsOsState = $WindowsOsState"
}
"  OutputResourceId = $OutputResourceId"

$labParts = $LabId.Split('/')
$labName = $labParts.Get($labParts.Length - 1)

"Fetching lab '$labName'"
$lab = Get-AzureRmResource -ResourceId "$LabId"

"Preparing deployment parameters"
$author = $Env:RELEASE_RELEASENAME
$authorType = 'release'
if ([string]::IsNullOrWhiteSpace($author))
{
    $author = $Env:BUILD_BUILDNUMBER
    $authorType = 'build'
}
$requestedFor = $Env:RELEASE_REQUESTEDFOR
if ([string]::IsNullOrWhiteSpace($requestedFor))
{
    $requestedFor = $Env:BUILD_REQUESTEDFOR
}
if ([string]::IsNullOrWhiteSpace($Description))
{
    $Description = "Custom image created from $authorType $author requested for $requestedFor."
}
$deploymentName = "Dtl$([Guid]::NewGuid().ToString().Replace('-', ''))"
$resourceGroupName = $lab.ResourceGroupName
$templateFile = Join-Path "$PSScriptRoot" 'new-azuredtl-customimage.json'

"Invoking deployment with the following parameters:"
"  DeploymentName = $deploymentName"
"  ResourceGroupName = $resourceGroupName"
"  TemplateFile = $templateFile"
"  TemplateParameters = -newCustomImageName `"$NewCustomImageName`" -labName `"$($lab.Name)`" -sourceLabVmId `"$SourceLabVMId`" -osType `"$OsType`" -linuxOsState `"$LinuxOsState`" -windowsOsState `"$WindowsOsState`" -author `"$author`" -description `"$Description`""

$resource = New-AzureRmResourceGroupDeployment -Name "$deploymentName" -ResourceGroupName "$resourceGroupName" -TemplateFile "$templateFile" -newCustomImageName "$NewCustomImageName" -labName "$($lab.Name)" -sourceLabVmId "$SourceLabVMId" -osType "$OsType" -linuxOsState "$LinuxOsState" -windowsOsState "$WindowsOsState" -author "$author" -description "$Description"

if ($OutputResourceId)
{
    # Capture the resource ID in the output variable.
    "Creating variable '$OutputResourceId' with value '$($resource.Outputs.`"$OutputResourceId`".Value)'"
    Set-TaskVariable -Variable $OutputResourceId -Value "$($resource.Outputs.`"$OutputResourceId`".Value)"
}

"Completing Azure DevTest Labs Create Custom Image Task"
