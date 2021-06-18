#----------------------------
# Vars
#----------------------------
param (
    [string]$resourceGroupName = "rg-landingzone-vikas",
    [string]$Location          = "westeurope",
    [string]$vnetName          = "vnet-hub-weu-001"
)

Write-Output "Requesting a Pulic IP on Azure in $($location) azure location"
$gwpip = New-AzPublicIpAddress `
    -Name "pip-vpngw-learning-weu-001" `
    -ResourceGroupName $resourceGroupName `
    -Location $Location `
    -AllocationMethod Dynamic `
    -Force


$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet
$gwipconfig = New-AzVirtualNetworkGatewayIpConfig `
    -Name gwipconfig1 `
    -SubnetId $subnet.Id `
    -PublicIpAddressId $gwpip.Id

Write-Output "Deploy VPN Gw"
New-AzVirtualNetworkGateway `
    -Name "vgw-hub-weu-001" `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -IpConfigurations $gwipconfig `
    -GatewayType Vpn `
    -VpnType RouteBased `
    -GatewaySku VpnGw1
    -Verbose