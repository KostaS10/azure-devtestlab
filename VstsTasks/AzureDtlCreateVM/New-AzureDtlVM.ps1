[CmdletBinding()]
Param(
    [string]$ConnectedServiceName,
    [string]$LabId,
    [string]$TemplateName,
    [string]$TemplateParameters,
    [string]$OutputResourceId
)

Import-Module Microsoft.TeamFoundation.DistributedTask.Task.Common
Import-Module Microsoft.TeamFoundation.DistributedTask.Task.Internal

"Starting Azure DevTest Labs Create VM Task"

"Task called with the following parameters:"
"  ConnectedServiceName = $ConnectedServiceName"
"  LabId = $LabId"
"  TemplateName = $TemplateName"
"  TemplateParameters = $TemplateParameters"
"  OutputResourceId = $OutputResourceId"

"Validating input parameters"
. (Join-Path "$PSScriptRoot" "AzureDtlUtils.ps1")
$vmName = Get-ParameterValue -Parameters $TemplateParameters -ParameterName 'newVMName'
Validate-TemplateParameters -Parameters $TemplateParameters
Validate-VMName -Name $vmName

$labParts = $LabId.Split('/')
$labName = $labParts.Get($labParts.Length - 1)

"Fetching lab '$labName'"
$lab = Get-AzureRmResource -ResourceId "$LabId"

"Preparing deployment parameters"
$deploymentName = "Dtl$([Guid]::NewGuid().ToString().Replace('-', ''))"
$resourceGroupName = $lab.ResourceGroupName
$templateFile = $TemplateName
if (-not [IO.Path]::IsPathRooted($TemplateName))
{
    $templateFile = Join-Path "$PSScriptRoot" "$TemplateName"
}
if (-not $TemplateParameters.Contains('-labName'))
{
    $TemplateParameters = "-labName '$($lab.Name)' $TemplateParameters"
}

"Invoking deployment with the following parameters:"
"  DeploymentName = $deploymentName"
"  ResourceGroupName = $resourceGroupName"
"  TemplateFile = $templateFile"
"  TemplatePamareters = $TemplateParameters"

$resource = Invoke-Expression -Command "New-AzureRmResourceGroupDeployment -Name `"$deploymentName`" -ResourceGroupName `"$resourceGroupName`" -TemplateFile `"$templateFile`" $TemplateParameters"

if ($OutputResourceId)
{
    # Capture the resource ID in the output variable.
    "Creating variable '$OutputResourceId' with value '$($resource.Outputs.`"$OutputResourceId`".Value)'"
    Set-TaskVariable -Variable $OutputResourceId -Value "$($resource.Outputs.`"$OutputResourceId`".Value)"
}

"Completing Azure DevTest Labs Create VM Task"
