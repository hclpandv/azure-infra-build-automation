#----------------------------
# Vars
#----------------------------
param (
    [string]$resourceGroupName = "rg-LearningApp-001",
    [string]$Location          = "westeurope",
    [string]$vnetName          = "vnet-hub-weu-001",
    [string]$vnetRg            = "rg-landingzone-vikas",
    [string]$snetName          = "snet-hub-mgmt",
    [string]$vmName            = "mgmt01",
    [switch]$publicIpNeeded
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

# if Public IP requested
if($publicIpNeeded){
    # Create a public IP address
    $publicIP = New-AzPublicIpAddress `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -Name "pip-$($vmName)" `
        -AllocationMethod Static `
        -IdleTimeoutInMinutes 4 `
        -Force
    # Deploy a NIC in the target vnet/subnet
    $nic = New-AzNetworkInterface `
        -Name "nic-$($vmName)" `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -SubnetId $subnetId `
        -PublicIpAddressId $publicIP.Id `
        -Force
}
else {
    # Create a virtual network card and associate with public IP address.
    $nic = New-AzNetworkInterface `
        -Name "$($vmName)-nic" `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -SubnetId $subnetId `
        -Force
}

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize `
    | Set-AzVMOperatingSystem -Linux -ComputerName $vmName -Credential $vmCred `
    | Set-AzVMSourceImage -PublisherName Canonical -Offer UbuntuServer -Skus 18.04-LTS -Version latest `
    | Add-AzVMNetworkInterface -Id $nic.Id

# VM Deployment
New-AzVm `
    -ResourceGroupName $resourceGroupName `
    -Location $Location `
    -VM $vmConfig `
    -Verbose
