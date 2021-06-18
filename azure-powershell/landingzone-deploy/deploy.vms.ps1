#----------------------------
# Vars
#----------------------------
param (
    [string]$resourceGroupName = "rg-LearningApp-001",
    [string]$Location          = "westeurope",
    [string]$vnet              = "vnet-hub-weu-001",
    [string]$snet              = "snet-hub-mgmt",
    [string]$vmName            = "mgmt01"
)

#----------------------------
# Azure resource deployment
#----------------------------
$AdminUser     = "vikiadmin"
$AdminPassword = ConvertTo-SecureString "d0nt%find%m3" -AsPlainText -Force
$vmCred        = New-Object System.Management.Automation.PSCredential($AdminUser, $AdminPassword)
$computerName  = "app01"
$vmSize        = "Standard_B1s"
$vmImage       = "UbuntuLTS"

# VM Deployment
New-AzVm `
    -image  $vmImage `
    -size $vmSize `
    -ResourceGroupName $resourceGroupName `
    -Name $vmName `
    -Location $Location `
    -Credential $vmCred `
    -VirtualNetworkName $vnet `
    -SubnetName $snet `
    -verbose
