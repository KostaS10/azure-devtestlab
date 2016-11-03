[CmdletBinding()]
Param(
    [string]$ConnectedServiceName,
    [string]$LabVMId
)

"Starting Azure DevTest Labs Delete VM Task"

"Task called with the following parameters:"
"  ConnectedServiceName = $ConnectedServiceName"
"  LabVMId = $LabVMId"

$labVMParts = $LabVMId.Split('/')
$labVMName = $labVMParts.Get($labVMParts.Length - 1)
$labName = $labVMParts.Get($labVMParts.IndexOf('labs') + 1)

"Deleting Lab VM '$labVMName' from Lab '$labName'"
Remove-AzureRmResource -ResourceId "$LabVMId" -Force | Out-Null

"Completing Azure DevTest Labs Delete VM Task"
