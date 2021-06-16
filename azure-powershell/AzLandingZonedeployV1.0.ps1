#----------------------------
# Vars
#----------------------------
$resourceGroupName = "rg-landingzone-vikas"
$Location          = "westeurope"

$vnets = @(
    #Hub vnet
    @{ 
        "name" = "vnet-weu-hub"
        "cidr" = "172.17.0.0/22" #1024 IPs
        "subnets" = @(
            @{  
                "name" = "snet-hub-mgmt"
                "cidr" = "172.17.0.0/27" #(32-5 | 27 Available)
                "serviceEndpoints" = @()
            }
            @{
                "name" = "snet-hub-dmz"
                "cidr" = "172.17.1.0/26" #(64-5 | 59 Available)
                "serviceEndpoints" = @()
            }
            @{
                "name" = "GatewaySubnet"
                "cidr" = "172.17.2.0/28" #(16-5 | 11 Available)
                "serviceEndpoints" = @()
            }    
        ) 
    }
    #spoke vnet 1
    @{ 
        "name" = "vnet-weu-spoke-01"
        "cidr" = "172.18.0.0/22" #1024 IPs
        "subnets" = @(
            @{  
                "name" = "snet-spoke1-web"
                "cidr" = "172.18.0.0/27" #(32-5 | 27 Available)
                "serviceEndpoints" = @()
            }
            @{
                "name" = "snet-spoke1-app"
                "cidr" = "172.18.1.0/26" #(64-5 | 59 Available)
                "serviceEndpoints" = @()
            }
            @{
                "name" = "snet-spoke1-db"
                "cidr" = "172.18.2.0/28" #(16-5 | 11 Available)
                "serviceEndpoints" = @("Microsoft.Storage", "Microsoft.Sql")
            }    
        ) 
    }
)

#-----------------------------
# Azure Resource Deployments
#-----------------------------

# Create a resource group.
New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

$vnets | ForEach-Object {
    Write-Output "Started working on vnet: $($_.name)"
    # subnet objects | subnet is not a separate service but a vnet config
    $subnets = @()
    $_.subnets | Where-Object {!($_.name -like "GatewaySubnet")} | ForEach-Object {
        # Deploy subnet NSGs
        Write-Output "Deploying NSG: $($_.name)-nsg"
        $nsg = New-AzNetworkSecurityGroup `
          -Name "$($_.name)-nsg" `
          -ResourceGroupName $resourceGroupName `
          -Location $Location `
          -Force
        # Define subnet config
        $subnetConfig = New-AzVirtualNetworkSubnetConfig `
            -Name $_.name `
            -AddressPrefix $_.cidr `
            -ServiceEndpoint $_.serviceEndpoints `
            -NetworkSecurityGroup $nsg
        $subnets += $subnetConfig
    }

    # Deploy Vnets
    Write-Output "deploying VNET: $($_)"
    $vnet = New-AzVirtualNetwork `
        -ResourceGroupName $resourceGroupName `
        -Location $Location `
        -Name $_.name `
        -AddressPrefix $_.cidr `
        -Subnet $subnets `
        -Force    
}