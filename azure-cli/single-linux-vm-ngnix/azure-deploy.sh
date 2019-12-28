#!/usr/bin/env bash

#---mgmt vars
SCRIPT_VERSION=1.0
TIME_STAMP=$(date +'%y%m%d%H%M' --utc)
DEPLOY_CODE="vikiazclideploy${TIME_STAMP}"

#---azure resource Vars
resource_group="${DEPLOY_CODE}-rg"
location="westeurope"
vnet="${DEPLOY_CODE}-vnet"
vnet_address="192.169.0.0/16"
subnet="${DEPLOY_CODE}-sbnt"
subnet_address="192.169.1.0/24"
nsg="${DEPLOY_CODE}-nsg"
vm_name="ubuntu-web01"
vm_size="Standard_B1s"
vm_nic="${vm_name}-nic"
vm_public_ip="${vm_name}-ip"
#---------------------------------
# main
#---------------------------------

# Create a resource group.
az group create --name $resource_group --location $location

# Create a virtual network.
az network vnet create --resource-group $resource_group --name $vnet --address-prefix $vnet_address \
    --location $location \
    --subnet-name $subnet --subnet-prefix $subnet_address
    
# Create a public IP address.
az network public-ip create --resource-group $resource_group --name $vm_public_ip

# Create a network security group.
az network nsg create --resource-group $resource_group --name $nsg

# Create a virtual network card and associate with public IP address and NSG.
az network nic create \
  --resource-group $resource_group \
  --name $vm_nic \
  --vnet-name $vnet \
  --subnet $subnet \
  --network-security-group $nsg \
  --public-ip-address $vm_public_ip

# Create a new virtual machine, this creates SSH keys if not present.
az vm create --resource-group $resource_group --name $vm_name --nics $vm_nic --image UbuntuLTS --generate-ssh-keys \
  --size $vm_size \
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
echo "VM: $vm_name created details below, access via SSH/Browser"
echo "============================================================="
echo "+++++++++++++++++++    OutPut    ++++++++++++++++++++++++++++"
echo "============================================================="
az vm list-ip-addresses --name $vm_name --output table
echo ""
