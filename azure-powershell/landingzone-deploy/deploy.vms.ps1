#----------------------------
# Vars
#----------------------------
param (
    [string]$resourceGroupName = "rg-LearningApp-001",
    [string]$Location          = "westeurope",
    [string]$vnetName          = "vnet-hub-weu-001",
    [string]$vnetRg            = "rg-landingzone-vikas",
    [string]$snetName          = "snet-hub-mgmt",
    [string]$vmName            = "mgmt01"
)

#----------------------------
# Azure resource deployment
#----------------------------
$AdminUser     = "vikiadmin"
$AdminPassword = ConvertTo-SecureString "d0nt%find%m3" -AsPlainText -Force
$vmCred        = New-Object System.Management.Automation.PSCredential($AdminUser, $AdminPassword)
$vmSize        = "Standard_B1s"
$vnet          = Get-AzVirtualNetwork -ResourceGroupName $vnetRg -Name $vnetName
$subnetId      = ($vnet.Subnets | Where-Object {$_.name -eq $snetName}).id

# Create a resource group.
New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

# Deploy a NIC in the target vnet/subnet
$nic = New-AzNetworkInterface `
    -Name "$($vmName)-nic" `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -SubnetId $subnetId

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize `
    | Set-AzVMOperatingSystem -Linux -ComputerName $vmName -Credential $vmCred `
    | Set-AzVMSourceImage -PublisherName Canonical -Offer UbuntuServer -Skus 18.04-LTS -Version latest `
    | Add-AzVMNetworkInterface -Id $nic.Id

# VM Deployment
New-AzVm `
    -ResourceGroupName $resourceGroupName `
    -Location $Location `
    -VM $vmConfig
