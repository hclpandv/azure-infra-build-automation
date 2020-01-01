<#
  .SYNOPSIS
    Login and Manage Azure resources via REST API

  .DESCRIPTION
    Script shows a demo to consume azure REST api services
#>

#--- Vars
$ScriptDir = Split-Path $MyInvocation.MyCommand.path
$Resource = "https://management.core.windows.net/"

#--- Main

# Import Utility Module
Import-Module -Name "$ScriptDir\module\utility" -Verbose -DisableNameChecking

# Load azure service principal credentials
if(Test-Path $ScriptDir\azureSpCredEnv.ps1){
   # Dot source Azure file
   . $ScriptDir\azureSpCredEnv.ps1
}
else{
   Write-Output "file .\azureSpCredEnv.ps1 must be present, exiting"
   exit 1
}

# Variables
$Resource = "https://management.core.windows.net/"
$ApiUri = "https://login.microsoftonline.com/$($env:ARM_TENANT_ID)/oauth2/token"

# Functions
Function New-AccessToken
{
    $Response = Get-AccessToken -GrantType client_credentials -ClientId $($env:ARM_CLIENT_ID) `
            -ClientSecret $($env:ARM_CLIENT_SECRET) -Resource $Resource -ApiUri $ApiUri
    $Token | ConvertTo-Json | Out-File "token.json" -Force
    Write-Output "New token generated."
    return $Response
}

# Get Access Token
if (!(Test-Path -Path "$ScriptDir\token.json"))
{
    Write-Output "Getting new token."
    $Token = New-AccessToken
}
else 
{
    $Token = Get-Content -Raw -Path "$ScriptDir\token.json" | ConvertFrom-Json
    # Check if token is expired.
    # $epoch = [datetime]"1/1/1970"
    #$ExpiresOn = $epoch.AddSeconds($Token.expires_on)
    $ExpiresOn = [datetime]$Token.expiresOn
    if ($ExpiresOn -lt [datetime]::Now)
    {
        Write-Output "Token has expired and will be renewed."
        $Token = New-AccessToken
    }
    else
    {
        Write-Output "Token is valid and ready to be used."
    }
}
# Get Azure Resource Groups
$ResourceGroupApiUri = "https://management.azure.com/subscriptions/$($env:ARM_SUBSCRIPTION_ID)/resourcegroups?api-version=2017-05-10"

$Headers = @{}

$Headers.Add("Authorization","$($Token.tokenType) "+ " " + "$($Token.accessToken)")

$ResourceGroups = Invoke-RestMethod -Method Get -Uri $ResourceGroupApiUri -Headers $Headers

Write-Output $ResourceGroups.value
