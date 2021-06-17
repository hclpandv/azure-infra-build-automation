#!/usr/bin/env bash

#----------------------------
# Vars
#----------------------------
resource_group="rg-landingzone-vikas"
location="westeurope"

vnet_name="vnet-weu-cli-demo-01"
vnet_cidr="172.17.0.0/22" #1024 IPs

declare -A subnets
subnets[snet-web]="172.17.0.0/27" #(32-5 | 27 Available)
subnets[snet-app]="172.17.1.0/26" #(64-5 | 59 Available)
subnets[snet-db]="172.17.2.0/28"  #(16-5 | 11 Available)

#-----------------------------
# Azure Resource Deployments
#-----------------------------

# Create a Resourcegroup
az group create --name $resource_group --location $location

# Deploy Vnets
az network vnet create \
    --resource-group $resource_group \
    --name $vnet_name \
    --address-prefix $vnet_cidr \
    --location $location

# Deploy NSGs
for snet_name in "${!subnets[@]}"; do
   az network nsg create --resource-group $resource_group --name $snet_name-nsg 
done 

# Add subnets
for key in "${!subnets[@]}"; do
    snet_name=$key 
    snet_cidr=${subnets[$key]}
    az network vnet subnet create \
        --resource-group $resource_group \
        --vnet-name $vnet_name \
        --name $snet_name \
        --address-prefixes $snet_cidr \
        --network-security-group $snet_name-nsg
done 

# Create an NSG rule to allow HTTP traffic in from the Internet to the web subnet.
az network nsg rule create \
    --resource-group $resource_group \
    --nsg-name $snet_web_name-nsg \
    --name AllowWebOnWebSnet \
    --access Allow \
    --protocol Tcp \
    --priority 500 \
    --source-address-prefix Internet \
    --source-port-range "*" \
    --destination-address-prefix "*" \
    --destination-port-range 80 443
    --description "Allow Internet to Web snet on ports 80,8080"

# future Help
#az group list --query "[].[name, location]" --output tsv | 
#while read -r x y; do
#    echo "name: $x"
#    echo "loca: $y"
#done



