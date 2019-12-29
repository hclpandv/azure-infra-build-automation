## Azure Resource Manager (ARM) Templates : Infra Build Automation Scripts

#### List of ARM Templates
* [single-linux-vm-ngnix](https://raw.githubusercontent.com/hclpandv/azure-infra-build-automation/dev/arm-templates/single-linux-vm-ngnix/azureDeploy.json)

#### How to deploy ?

* Az-Cli

```bash
# Clone this repo
git clone https://github.com/hclpandv/azure-infra-build-automation.git
cd azure-infra-build-automation/arm-templates/<target_arm_template_dir> #i.e single-linux-vm-ngnix
# Create a resource group for deployment of ARM template resource
az group create --name target_resource_group_name --location westindia
# Validate your Template file
az group deployment validate --resource-group target_resource_group_name --template-file azureDeploy.json
# Deploy Using Template file
az group deployment create --resource-group target_resource_group_name --template-file azureDeploy.json \
  #--template-uri https://raw.githubusercontent.com/hclpandv/azure-infra-build-automation/dev/arm-templates/single-linux-vm-ngnix/azureDeploy.json  

# Single cmd cleanup
az group delete --name target_resource_group_name --verbose --no-wait -y
```

* PowerShell

```powershell
#clone this repo
git clone https://github.com/hclpandv/azure-infra-build-automation.git
cd .\azure-infra-build-automation\arm-templates\<target_arm_template_dir>\
# Create a resource group for deployment of ARM template resources
New-AzResourceGroup -Name target_resource_group_name -Location westindia
# Validate your Template file
Test-AzResourceGroupDeployment -ResourceGroupName target_resource_group_name -TemplateFile .\azureDeploy.json
# Deploy Using Template file
New-AzResourceGroupDeployment -ResourceGroupName target_resource_group_name  -TemplateFile .\azureDeploy.json

# Single cmd cleanup
Remove-AzResourceGroup -Name test -Force -Verbose
# Dont want to wait for the cmd to complete
Remove-AzResourceGroup -Name test -Force -AsJob 
```
