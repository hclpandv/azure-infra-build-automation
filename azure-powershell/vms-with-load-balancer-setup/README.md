## Load Balancer with Availability Set

Load balancer is routing traffic:

                / ---> 10.0.0.4
52.233.250.39  |  ---> 10.0.0.5
                \ ---> 10.0.0.6

```
Login with lb public IP (3 Vms on 3 diff port 4221,4222,4223) 

root@NDL01252:~# az vm list-ip-addresses --resource-group myResourceGroup --output table
VirtualMachine    PrivateIPAddresses
----------------  --------------------
myVM1             10.0.0.4
myVM2             10.0.0.5
myVM3             10.0.0.6
root@NDL01252:~# ssh vikiadmin@52.233.250.39 -p 4222 
```
