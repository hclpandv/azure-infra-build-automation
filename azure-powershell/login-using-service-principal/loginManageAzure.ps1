<#
  .SYNOPSIS
    Login and Manage Azure resources

  .DESCRIPTION
    Script uses Azure Service Principle to login Azure and PowerShell Az module to manage resources
#>

#--- Vars
$ScriptDir = Split-Path $MyInvocation.MyCommand.path


#--- Main

# Load azure service principal credentials
if(Test-Path $ScriptDir\azureSpCredEnv.ps1){
   # Dot source Azure file
   . $ScriptDir\azureSpCredEnv.ps1
}
else{
   Write-Output "file .\azureSpCredEnv.ps1 must be present, exiting"
   exit 1
}

# Login to azure
$passwd = ConvertTo-SecureString "$env:ARM_CLIENT_SECRET" -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($env:ARM_CLIENT_ID, $passwd)

Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $env:ARM_TENANT_ID -Verbose

# Exit if Azure Login failed
if(! $?){
  Write-Output "Azure Login Failed, Please validate your credentials in azureSpCredEnv.ps1 file"
  exit 1
}

# Manage Azure Resources
Get-AzResourceGroup | ft
# Create a New Azure Resource Group
New-AzResourceGroup -Name "created-using-service-principal-powershell-rg" -Location "eastus"
