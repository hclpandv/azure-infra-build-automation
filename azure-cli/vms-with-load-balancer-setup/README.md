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

```
root@NDL01252:~# az vm list --output table

Name     ResourceGroup      Location    Zones
-------  -----------------  ----------  -------
vikiVM1  VIKIRESOURCEGROUP  westeurope  1
vikiVM2  VIKIRESOURCEGROUP  westeurope  2
vikiVM3  VIKIRESOURCEGROUP  westeurope  3
```

```
root@NDL01252:~# az vm list-ip-addresses --resource-group vikiResourceGroup --output table

VirtualMachine    PrivateIPAddresses
----------------  --------------------
vikiVM1           10.0.0.4
vikiVM2           10.0.0.5
vikiVM3           10.0.0.6
```
```
root@NDL01252:~# az resource list --resource-group vikiResourceGroup --output table

Name                                               ResourceGroup      Location    Type                                  
-------------------------------------------------  -----------------  ----------  --------------------------------------- 
vikiVM1_OsDisk_1_b6ead9e8f66d44eab1b790c23c0e59d0  VIKIRESOURCEGROUP  westeurope  Microsoft.Compute/disks
vikiVM2_OsDisk_1_90471e3bd9d5472796a55825d03b2ca1  VIKIRESOURCEGROUP  westeurope  Microsoft.Compute/disks
vikiVM3_OsDisk_1_c5435b54ee5143f6baf450cc7224ad88  VIKIRESOURCEGROUP  westeurope  Microsoft.Compute/disks
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
