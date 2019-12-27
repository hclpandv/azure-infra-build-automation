<#
   Script to Create a single VM with IIS
   accessible over internet on port 80
   rdp port 3389 open    
#>

#---Mgmt Vars
$ScriptVersion = 1.0
$DeploymentCode = "vikipsdeploy$(Get-Date -format yyMMddhhmm)"

#---- Vars
$ResourceGroup = "$($DeploymentCode)-rg"
$Location = "westindia"
$VnetName = "$($DeploymentCode)-vnet"
$VnetAddress = "11.66.0.0/22" #11.66.0.0 - 11.66.3.256
$FrontendSubnetConfig = @{
                Name = "frontendsubnet";
                AddressPrefix = "11.66.1.0/24"; #11.66.1.0 - 11.66.1.255 
}

$BackendSubnetConfig = @{
                Name = "backendsubnet";
                AddressPrefix = "11.66.0.0/24"; #11.66.0.0 - 11.66.0.255
}

$VmAdminUser = "vikiadmin"
$VmPassword = ConvertTo-SecureString "d0nt%find%m3" -AsPlainText -Force
$VmCred = New-Object System.Management.Automation.PSCredential ($vmAdminUser, $vmPassword);
$VmImageConfig = @{
    PublisherName = "localhost";
    Offer = "WindowsServer"
    Skus = "2012-R2-Datacenter"
    Version = "latest"
}

$ComputerName = "viki-win-web-server-01"
$VmName = "viki-win-web-server-01"
$VmSize = "Standard_B1s"

#----------------------------
#---- Main
#----------------------------

#Create Resource group
New-AzResourceGroup -Name $ResourceGroup -Location $Location

#Create Vnet and Subnet
$frontendSubnet = New-AzVirtualNetworkSubnetConfig @FrontendSubnetConfig
$backendSubnet  = New-AzVirtualNetworkSubnetConfig @BackendSubnetConfig
$vnet = New-AzVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroup `
-Location centralus -AddressPrefix $VnetAddress -Subnet $frontendSubnet,$backendSubnet

# Create a public IP address
$PublicIP = New-AzPublicIpAddress -ResourceGroupName $ResourceGroup -Location $Location `
  -Name "$($DeploymentCode)-public-ip" -AllocationMethod Static -IdleTimeoutInMinutes 4

# Create an inbound network security group rule for port 22
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig -Name nsgRuleSSH  -Protocol Tcp `
  -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
  -DestinationPortRange 3389 -Access Allow

# Create an inbound network security group rule for port 80
$nsgRuleHTTP = New-AzNetworkSecurityRuleConfig -Name nsgRuleHTTP  -Protocol Tcp `
  -Direction Inbound -Priority 2000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
  -DestinationPortRange 80 -Access Allow

# Create a network security group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroup -Location $Location `
  -Name "$($DeploymentCode)-nsg" -SecurityRules $nsgRuleSSH,$nsgRuleHTTP

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface -Name "$($DeploymentCode)-nic" -ResourceGroupName $ResourceGroup -Location $location `
  -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $PublicIP.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$VmConfig = New-AzVMConfig -VMName $VmName -VMSize $VmSize | `
Set-AzVMOperatingSystem -Windows -ComputerName $ComputerName -Credential $VmCred -ProvisionVMAgent -EnableAutoUpdate | `
Set-AzVMSourceImage @VmImageConfig | `
Add-AzVMNetworkInterface -Id $nic.Id

# Create a virtual machine
New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $VmConfig

# Define the script for your Custom Script Extension to run
$PublicSettings = @{
    "fileUris" = (,"https://raw.githubusercontent.com/hclpandv/azure-infra-build-automation/dev/azure-powershell/single-windows-vm-iis/setup-iis.ps1");
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File setup-iis.ps1"
}

# Use Custom Script Extension to install IIS and configure basic website
Set-AzVMExtension -ExtensionName "CustomScript-iis" -ResourceGroupName $resourceGroup -VMName $VmName `
  -Publisher "Microsoft.Azure.Extensions" -ExtensionType "CustomScript" -TypeHandlerVersion 2.0 `
  -SettingString $PublicSettings -Location $location

# Get IP address of VM
(Get-AzPublicIpAddress -Name "mypublicdns$($DeploymentCode)").IpAddress
