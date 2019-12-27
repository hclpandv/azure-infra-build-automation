#!/usr/bin/env bash

#---mgmt vars
SCRIPT_VERSION=1.0
TIME_STAMP=$(date +'%Y%m%d%H%M') #For Logname
DEPLOY_CODE="viki${TIME_STAMP}"
#---azure resource Vars
resource_group="single-linux-vm-nginx-${DEPLOY_CODE}-rg"
location="westeurope"
vnet="${DEPLOY_CODE}-vnet"
subnet="${DEPLOY_CODE}-sbnt"
vm_name="viki-ubuntu-web-server-02"
#---------------------------------
# main
#---------------------------------

# Create a resource group.
az group create --name $resource_group --location $location

# Create a virtual network.
az network vnet create --resource-group $resource_group --name $vnet --subnet-name $subnet

# Create a public IP address.
az network public-ip create --resource-group $resource_group --name viki-public-ip

# Create a network security group.
az network nsg create --resource-group $resource_group --name viki-nsg

# Create a virtual network card and associate with public IP address and NSG.
az network nic create \
  --resource-group $resource_group \
  --name viki-nic \
  --vnet-name $vnet \
  --subnet $subnet \
  --network-security-group viki-nsg \
  --public-ip-address viki-public-ip

# Create a new virtual machine, this creates SSH keys if not present.
az vm create --resource-group $resource_group --name $vm_name --nics viki-nic --image UbuntuLTS --generate-ssh-keys \
  --admin-username vikiadmin \
  --custom-data cloud-init.txt

# Open port 22 to allow SSh traffic to host.
az vm open-port --port 22 --priority 100 --resource-group $resource_group --name $vm_name

# Open port 80 to allow http traffic to host.
az vm open-port --port 80 --priority 110 --resource-group $resource_group --name $vm_name

#------------------------------ Use CustomScript extension to install NGINX.(Un-comment if needed)----------------
#az vm extension set \
#  --publisher Microsoft.Azure.Extensions \
#  --version 2.0 \
#  --name CustomScript \
#  --vm-name $vm_name\
#  --resource-group $resource_group \
#  --settings '{"commandToExecute":"apt-get -y update && apt-get -y install nginx"}'
#------------------------------------------------------------------------------------------------------------------

# Output the public IP address to access the site in a web browser
az network public-ip show \
  --resource-group $resource_group \
  --name viki-public-ip \
  --query [ipAddress]
