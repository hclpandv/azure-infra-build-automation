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
                "name" = "snet-web"
                "cidr" = "172.17.0.0/27" #(32-5 | 27 Available)
                "serviceEndpoints" = @()
            }
            @{
                "name" = "snet-app"
                "cidr" = "172.17.1.0/26" #(64-5 | 59 Available)
                "serviceEndpoints" = @()
            }
            @{
                "name" = "snet-db"
                "cidr" = "172.17.2.0/28" #(16-5 | 11 Available)
                "serviceEndpoints" = @("Microsoft.Storage", "Microsoft.Sql")
            }    
        ) 
    }
    #spoke vnet 1
    @{ 
        "name" = "vnet-weu-spoke-01"
        "cidr" = "172.17.0.0/22" #1024 IPs
        "subnets" = @(
            @{  
                "name" = "snet-web"
                "cidr" = "172.17.0.0/27" #(32-5 | 27 Available)
                "serviceEndpoints" = @()
            }
            @{
                "name" = "snet-app"
                "cidr" = "172.17.1.0/26" #(64-5 | 59 Available)
                "serviceEndpoints" = @()
            }
            @{
                "name" = "snet-db"
                "cidr" = "172.17.2.0/28" #(16-5 | 11 Available)
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
    # subnet objects | subnet is not a separate service but a vnet config
    $subnets = @()
    $_.subnets | ForEach-Object {
        $subnetConfig  = New-AzVirtualNetworkSubnetConfig `
            -Name $_.name `
            -AddressPrefix $_.cidr `
            -ServiceEndpoint $_.serviceEndpoints
        $subnets += $subnetConfig
    }

    # Deploy Vnets
    $vnet = New-AzVirtualNetwork `
        -ResourceGroupName $resourceGroupName `
        -Location $Location `
        -Name $_.name `
        -AddressPrefix $_.cidr `
        -Subnet $subnets `
        -Force    
}