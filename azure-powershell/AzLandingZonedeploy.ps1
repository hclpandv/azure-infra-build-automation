#----------------------------
# Vars
#----------------------------
$resourceGroupName = "rg-landingzone-vikas"
$subscriptionId    = "212dfd1b-6b16-4834-aad1-b093e0cd3382" 
$Location          = "westeurope"

$vnetdef = @{ 
    "name" = "vnet-weu-demo-01"
    "cidr" = "172.17.0.0/22" #1024 IPs
    "subnets" = @(
        @{  
            "name" = "web"
            "cidr" = "172.17.0.0/27" #(32-5 | 27 Available)
            "serviceEndpoints" = @()
        }
        @{
            "name" = "app"
            "cidr" = "172.17.1.0/26" #(64-5 | 59 Available)
            "serviceEndpoints" = @()
        }
        @{
            "name" = "db"
            "cidr" = "172.17.2.0/28" #(16-5 | 11 Available)
            "serviceEndpoints" = @("Microsoft.Storage", "Microsoft.Sql")
        }    
    ) 
}

#-----------------------------
# Azure Resource Deployments
#-----------------------------

# Safety Switch
if((Get-AzContext).Subscription.Id -ne $subscriptionId){
    Write-Output "PowerShell Authentication issue. Pls ensure you are logged in to correct subscription"
    exit
}

# Create a resource group.
New-AzResourceGroup -Name $resourceGroupName -Location $location

# subnet objects | subnet is not a separate service but a vnet config
$objs = @()
$subnets = $vnetdef.subnets | ForEach-Object {
    $subnetConfig  = New-AzVirtualNetworkSubnetConfig `
        -Name $_.name `
        -AddressPrefix $_.cidr `
        -ServiceEndpoint $_.serviceEndpoints `
    $objs += $subnetConfig
    $objs
}

# Deploy Vnets
$vnet = New-AzVirtualNetwork `
    -ResourceGroupName $resourceGroupName `
    -Location $Location `
    -Name $vnetdef.name `
    -AddressPrefix $vnetdef.cidr `
    -Subnet $
    -Force