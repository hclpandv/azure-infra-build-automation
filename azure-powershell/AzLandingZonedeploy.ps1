#----------------------------
# Vars
#----------------------------

$resourceGroupName = "RG_Vikas.Pandey"
$subscriptionId    = "cc934d76-6d72-49cb-a908-81217ad4ae29"  # DCS-EM-AZ3
$infraLocation     = (Get-AzResourceGroup -name $resourceGroupName).Location

$vnetdef = @{ 
    "name" = "vnet-weu-demo-03"
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

# Deploy Vnets
$vnet = New-AzVirtualNetwork `
    -ResourceGroupName $resourceGroupName `
    -Location $infraLocation `
    -Name $vnetdef.name `
    -AddressPrefix $vnetdef.cidr `
    -Force

# Add subnets
$vnetdef.subnets | ForEach-Object {
    $subnetConfig  = Add-AzVirtualNetworkSubnetConfig `
        -Name $_.name `
        -AddressPrefix $_.cidr `
        -ServiceEndpoint $_.serviceEndpoints `
        -VirtualNetwork $vnet

}
#commit the changes
$vnet | Set-AzVirtualNetwork