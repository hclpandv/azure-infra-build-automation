#!/usr/bin/env bash

#----------------------------
# Vars
#----------------------------
resource_group="rg-landingzone-vikas"
subscription_id="212dfd1b-6b16-4834-aad1-b093e0cd3382"
location="westeurope"

vnet_name="vnet-weu-cli-demo-01"
vnet_cidr="172.17.0.0/22" #1024 IPs
snet_web_name="snet-web"
snet_web_cidr="172.17.0.0/27" #(32-5 | 27 Available)
snet_app_name="snet-app"
snet_app_cidr="172.17.1.0/26" #(64-5 | 59 Available)
snet_db_name="snet-db"
snet_db_cidr="172.17.2.0/28" #(16-5 | 11 Available)
#-----------------------------
# Azure Resource Deployments
#-----------------------------
# safety switch
current_subscription_id=$(az account show --query 'id' -o tsv)
if [ $current_subscription_id != $subscription_id ]; then
  echo "Azure Login issue, Please validate you are logged in to correct subscription"
  exit 1
fi

# Create a Resourcegroup
az group create --name $resource_group --location $location

# Deploy Vnets
az network vnet create \
    --resource-group $resource_group \
    --name $vnet_name \
    --address-prefix $vnet_cidr \
    --location $location

# Deploy NSGs
az network nsg create --resource-group $resource_group --name $snet_web_name-nsg
az network nsg create --resource-group $resource_group --name $snet_app_name-nsg
az network nsg create --resource-group $resource_group --name $snet_db_name-nsg

# Add subnets
az network vnet subnet create \
    --resource-group $resource_group \
    --vnet-name $vnet_name \
    --name $snet_web_name \
    --address-prefixes $snet_web_cidr \
    --network-security-group $snet_web_name-nsg

az network vnet subnet create \
    --resource-group $resource_group \
    --vnet-name $vnet_name \
    --name $snet_app_name \
    --address-prefixes $snet_app_cidr \
    --network-security-group $snet_app_name-nsg

az network vnet subnet create \
    --resource-group $resource_group \
    --vnet-name $vnet_name \
    --name $snet_db_name \
    --address-prefixes $snet_db_cidr \
    --network-security-group $snet_db_name-nsg \
    --service-endpoints "Microsoft.Storage" "Microsoft.Sql"

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


