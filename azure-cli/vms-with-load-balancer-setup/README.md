## Load Balancer with VMs in Availability Set

Load balancer is routing traffic:

```
                / ---> 10.0.0.4
52.233.250.39  |  ---> 10.0.0.5
                \ ---> 10.0.0.6
```
```
Login with lb public IP (3 Vms on 3 diff port 4221,4222,4223) 

root@NDL01252:~# az vm list-ip-addresses --resource-group vikiResourceGroup --output table
VirtualMachine    PrivateIPAddresses
----------------  --------------------
vikiVM1             10.0.0.4
vikiVM2             10.0.0.5
vikiVM3             10.0.0.6
root@NDL01252:~# ssh vikiadmin@52.233.250.39 -p 4222 
```

```
root@NDL01252:~# az resource list --resource-group vikiResourceGroup --output table

Name                                             ResourceGroup    Location    Type                                     
-----------------------------------------------  ---------------  ----------  --------------------------------------- 
vikiAvailabilitySet                                vikiResourceGroup  westeurope  Microsoft.Compute/availabilitySets
vikiVM1_OsDisk_1_e7fc7f2189d1430b8ec0f51034540f13  VIKIRESOURCEGROUP  westeurope  Microsoft.Compute/disks
vikiVM2_OsDisk_1_71a31e015176472fbf1d8cf587f46c2a  VIKIRESOURCEGROUP  westeurope  Microsoft.Compute/disks
vikiVM3_OsDisk_1_805e472864ed4ca9a64521717dcc3ca3  VIKIRESOURCEGROUP  westeurope  Microsoft.Compute/disks
vikiVM1                                            vikiResourceGroup  westeurope  Microsoft.Compute/virtualMachines
vikiVM2                                            vikiResourceGroup  westeurope  Microsoft.Compute/virtualMachines
vikiVM3                                            vikiResourceGroup  westeurope  Microsoft.Compute/virtualMachines
vikiLoadBalancer                                   vikiResourceGroup  westeurope  Microsoft.Network/loadBalancers
vikiNic1                                           vikiResourceGroup  westeurope  Microsoft.Network/networkInterfaces
vikiNic2                                           vikiResourceGroup  westeurope  Microsoft.Network/networkInterfaces
vikiNic3                                           vikiResourceGroup  westeurope  Microsoft.Network/networkInterfaces
vikiNetworkSecurityGroup                           vikiResourceGroup  westeurope  Microsoft.Network/networkSecurityGroups
vikiPublicIP                                       vikiResourceGroup  westeurope  Microsoft.Network/publicIPAddresses
vikiVnet                                           vikiResourceGroup  westeurope  Microsoft.Network/virtualNetworks
```

## Load Balancer with VMs in different Availability zones
