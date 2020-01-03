#!/bin/bash

#-----------------------------------------------------------------------------------------
# Load balance traffic to VMs for high availability
# After running the script, you will have three virtual machines, 
# joined to an Azure Availability Set, 
# and accessible through an Azure Load Balancer.
#-----------------------------------------------------------------------------------------

# Create a resource group.
az group create --name vikiResourceGroup --location westeurope

# Create a virtual network.
az network vnet create --resource-group vikiResourceGroup --location westeurope --name vikiVnet --subnet-name vikiSubnet

# Create a public IP address.
az network public-ip create --resource-group vikiResourceGroup --name vikiPublicIP

# Create an Azure Load Balancer.
az network lb create --resource-group vikiResourceGroup --name vikiLoadBalancer --public-ip-address vikiPublicIP \
  --frontend-ip-name vikiFrontEndPool --backend-pool-name vikiBackEndPool

# Creates an LB probe on port 80.
az network lb probe create --resource-group vikiResourceGroup --lb-name vikiLoadBalancer \
  --name vikiHealthProbe --protocol tcp --port 80

# Creates an LB rule for port 80.
az network lb rule create --resource-group vikiResourceGroup --lb-name vikiLoadBalancer --name vikiLoadBalancerRuleWeb \
  --protocol tcp --frontend-port 80 --backend-port 80 --frontend-ip-name vikiFrontEndPool \
  --backend-pool-name vikiBackEndPool --probe-name vikiHealthProbe

# Create three NAT rules for port 22.
for i in `seq 1 3`; do
  az network lb inbound-nat-rule create \
  --resource-group vikiResourceGroup --lb-name vikiLoadBalancer \
  --name vikiLoadBalancerRuleSSH$i --protocol tcp \
  --frontend-port 422$i --backend-port 22 \
  --frontend-ip-name vikiFrontEndPool
done

# Create a network security group
az network nsg create --resource-group vikiResourceGroup --name vikiNetworkSecurityGroup

# Create a network security group rule for port 22.
az network nsg rule create --resource-group vikiResourceGroup --nsg-name vikiNetworkSecurityGroup --name vikiNetworkSecurityGroupRuleSSH \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 22 --access allow --priority 1000

# Create a network security group rule for port 80.
az network nsg rule create --resource-group vikiResourceGroup --nsg-name vikiNetworkSecurityGroup --name vikiNetworkSecurityGroupRuleHTTP \
  --protocol tcp --direction inbound --priority 1001 --source-address-prefix '*' --source-port-range '*' \
  --destination-address-prefix '*' --destination-port-range 80 --access allow --priority 2000

# Create three virtual network cards and associate with public IP address and NSG.
for i in `seq 1 3`; do
  az network nic create \
  --resource-group vikiResourceGroup --name vikiNic$i \
  --vnet-name vikiVnet --subnet vikiSubnet \
  --network-security-group vikiNetworkSecurityGroup --lb-name vikiLoadBalancer \
  --lb-address-pools vikiBackEndPool --lb-inbound-nat-rules vikiLoadBalancerRuleSSH$i
done

# Create an availability set.
az vm availability-set create --resource-group vikiResourceGroup --name vikiAvailabilitySet --platform-fault-domain-count 3 --platform-update-domain-count 3

# Create three virtual machines, this creates SSH keys if not present.
for i in `seq 1 3`; do
  az vm create \
  --resource-group vikiResourceGroup \
  --name vikiVM$i \
  --admin-username vikiadmin \
  --availability-set vikiAvailabilitySet \
  --nics vikiNic$i \
  --image UbuntuLTS \
  --generate-ssh-keys \
  --no-wait
done
