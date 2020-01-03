#!/bin/bash

#---------------------------------------------------------------------------------------------
# Load balance VMs across availability zones :
# After running the script, you will have three virtual machines across all availability zones 
# within a region that are accessible through an Azure Standard Load Balancer
#---------------------------------------------------------------------------------------------

# Create a resource group.
az group create \
  --name vikiResourceGroup \
  --location westeurope

# Create a virtual network.
az network vnet create \
  --resource-group vikiResourceGroup \
  --location westeurope \
  --name vikiVnet \
  --subnet-name vikiSubnet

# Create a zonal Standard public IP address.
az network public-ip create \
  --resource-group vikiResourceGroup \
  --name vikiPublicIP \
  --sku Standard    

# Create an Azure Load Balancer.
az network lb create \
  --resource-group vikiResourceGroupLB \
  --name vikiLoadBalancer \
  --public-ip-address vikiPublicIP \
  --frontend-ip-name vikiFrontEndPool \
  --backend-pool-name vikiBackEndPool \
  --sku Standard

# Creates an LB probe on port 80.
az network lb probe create \
    --resource-group vikiResourceGroup \
    --lb-name vikiLoadBalancer \
    --name vikiHealthProbe \
    --protocol tcp \
    --port 80

# Creates an LB rule for port 80.
az network lb rule create \
  --resource-group vikiResourceGroup \
  --lb-name vikiLoadBalancer \
  --name vikiLoadBalancerRuleWeb \
  --protocol tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name vikiFrontEndPool \
  --backend-pool-name vikiBackEndPool \
  --probe-name vikiHealthProbe

# Create three NAT rules for port 22.
for i in `seq 1 3`; do
  az network lb inbound-nat-rule create \
    --resource-group vikiResourceGroup \
    --lb-name vikiLoadBalancer \
    --name vikiLoadBalancerRuleSSH$i \
    --protocol tcp \
    --frontend-port 422$i \
    --backend-port 22 \
    --frontend-ip-name vikiFrontEndPool
done

# Create a network security group
 az network nsg create \
  --resource-group vikiResourceGroup \
  --name vikiNetworkSecurityGroup

# Create a network security group rule for port 22.
 az network nsg rule create \
  --resource-group vikiResourceGroup \
  --nsg-name vikiNetworkSecurityGroup \
  --name vikiNetworkSecurityGroupRuleSSH \
  --protocol tcp \
  --direction inbound \
  --source-address-prefix '*' \
  --source-port-range '*'  \
  --destination-address-prefix '*' \
  --destination-port-range 22 \
  --access allow \
  --priority 1000

# Create a network security group rule for port 80.
  az network nsg rule create \
   --resource-group vikiResourceGroup \
   --nsg-name vikiNetworkSecurityGroup \
   --name vikiNetworkSecurityGroupRuleHTTP \
   --protocol tcp \
   --direction inbound \
   --source-address-prefix '*' \
   --source-port-range '*' \
   --destination-address-prefix '*' \
   --destination-port-range 80 \
   --access allow \
   --priority 2000

# Create three virtual network cards and associate with load balancer and NSG.
for i in `seq 1 3`; do
  az network nic create \
    --resource-group vikiResourceGroup \
    --name vikiNic$i \
    --vnet-name vikiVnet \
    --subnet vikiSubnet \
    --network-security-group vikiNetworkSecurityGroup \
    --lb-name vikiLoadBalancer \
    --lb-address-pools vikiBackEndPool \
    --lb-inbound-nat-rules vikiLoadBalancerRuleSSH$i
done

# Create three virtual machines, this creates SSH keys if not present.
for i in `seq 1 3`; do
  az vm create \
    --resource-group vikiResourceGroup \
    --name vikiVM$i \
    --admin-username vikiadmin \
    --zone $i \
    --nics vikiNic$i \
    --image UbuntuLTS \
    --generate-ssh-keys \
    --no-wait
done
