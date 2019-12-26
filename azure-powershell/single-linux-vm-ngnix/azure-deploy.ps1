<#
   Script to Create a single VM with ngnix
   accessible over internet on port 80
   ssh port 22 open    
#>

#---Mgmt Vars
$scriptVersion = 1.0
$deploymentCode = "viki$(Get-Random)"

#---Azure Global Vars
$resourceGroup = "single-linux-vm-nginx-$($deploymentCode)-rg"
$location = "westindia"
$vnet = "$($deploymentCode)-vnet"
$subnet = "$($deploymentCode)-sbnt"


#---Resource Vars
$vmAdminUser = "vikiadmin"
$vmPassword = ConvertTo-SecureString "d0nt%find%m3" -AsPlainText -Force
$vmCred = New-Object System.Management.Automation.PSCredential ($vmAdminUser, $vmPassword);

$computerName = "viki-ubuntu-web-server-01"
$vmName = "viki-ubuntu-web-server-01"
$vmSize = "Standard_B1s"

#-----------------------------
#---Main
#-----------------------------

# Create a resource group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnet -AddressPrefix 192.168.1.0/24

# Create a virtual network
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Location $location `
  -Name $vnet -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig

# Create a public IP address and specify a DNS name
$publicIP = New-AzPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `
  -Name "mypublicdns$($deploymentCode)" -AllocationMethod Static -IdleTimeoutInMinutes 4

# Create an inbound network security group rule for port 22
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig -Name nsgRuleSSH  -Protocol Tcp `
  -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
  -DestinationPortRange 22 -Access Allow

# Create an inbound network security group rule for port 80
$nsgRuleHTTP = New-AzNetworkSecurityRuleConfig -Name nsgRuleHTTP  -Protocol Tcp `
  -Direction Inbound -Priority 2000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
  -DestinationPortRange 80 -Access Allow

# Create a network security group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location `
  -Name "$($deploymentCode)-nsg" -SecurityRules $nsgRuleSSH,$nsgRuleHTTP

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface -Name "$($deploymentCode)-nic" -ResourceGroupName $resourceGroup -Location $location `
  -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIP.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize | `
Set-AzVMOperatingSystem -Linux -ComputerName $computerName -Credential $vmCred | `
Set-AzVMSourceImage -PublisherName Canonical -Offer UbuntuServer -Skus 14.04.2-LTS -Version latest | `
Add-AzVMNetworkInterface -Id $nic.Id

# Create a virtual machine
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig

# Install NGINX.
$PublicSettings = '{"commandToExecute":"apt-get -y update && apt-get -y install nginx"}'

Set-AzVMExtension -ExtensionName "NGINX" -ResourceGroupName $resourceGroup -VMName $vmName `
  -Publisher "Microsoft.Azure.Extensions" -ExtensionType "CustomScript" -TypeHandlerVersion 2.0 `
  -SettingString $PublicSettings -Location $location
