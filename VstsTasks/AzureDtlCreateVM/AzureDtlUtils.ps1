function Get-ParameterValue
{
    [CmdletBinding()]
    Param(
        [string]$Parameters,
        [string]$ParameterName
    )

    $pattern = '\-(?<k>\w+)\s+(?<v>\''.*?\''|\$\(.*\)?|\(.*\)?)'

    $value = [regex]::Matches($Parameters, $pattern) | % { if ($_.Groups[1].Value -eq $ParameterName) { return $_.Groups[2].Value } }
    if ($value)
    {
        $value = $value.Trim("'")
    }
    
    return $value
}

function Validate-TemplateParameters
{
    [CmdletBinding()]
    Param(
        [string]$Parameters
    )

    $defaultValues = @{
        NewVMName = '<Enter VM Name>'
        UserName = '<Enter User Name>'
        Password = '<Enter User Password>'
    }

    $vmName = Get-ParameterValue -Parameters $TemplateParameters -ParameterName 'newVMName'
    $userName = Get-ParameterValue -Parameters $TemplateParameters -ParameterName 'userName'
    $password = Get-ParameterValue -Parameters $TemplateParameters -ParameterName 'password'

    $mustReplaceDefaults = $false
    if ($vmName -and $vmName.Contains($defaultValues.NewVMName))
    {
        'Warning: -newVMName value should be replaced with non-default.'
        $mustReplaceDefaults = $true
    }
    if ($userName -and $userName.Contains($defaultValues.UserName))
    {
        'Warning: -userName value should be replaced with non-default.'
        $mustReplaceDefaults = $true
    }
    if ($password -and $password.Contains($defaultValues.Password))
    {
        'Warning: -password value should be replaced with non-default.'
        $mustReplaceDefaults = $true
    }

    if ($mustReplaceDefaults)
    {
        throw 'Default values must be replaced. Please review the Template Parameters and modify as needed.'
    }
}

function Validate-VMName
{
    [CmdletBinding()]
    Param(
        [string]$Name,
        [int]$MaxNameLength = 15
    )

    if ([string]::IsNullOrWhiteSpace($Name))
    {
        throw "Invalid VM name '$Name'. Name must be specified."
    }
    
    if ($Name.Length -gt $MaxNameLength)
    {
        throw "Invalid VM name '$Name'. Name must be between 1 and $MaxNameLength characters."
    }

    $regex = [regex]'^(?=.*[a-zA-Z/-]+)[0-9a-zA-Z/-]*$'
    if (-not $regex.Match($Name).Success)
    {
        throw "Invalid VM name '$Name'. Name cannot be entirely numeric and cannot contain most special characters."
    }
}
