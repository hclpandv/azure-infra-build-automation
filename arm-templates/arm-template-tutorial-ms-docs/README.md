### Tutorial: Create and deploy your first Azure Resource Manager template  

https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-tutorial-create-first-template?tabs=azure-powershell

* Tutorial followed as it is..
* Please observe commit messages to see the changes in each iteration


#### Commandline to develope and deploy ARM templates in incremental mode

* Better suited for agile developement

```bash
az group deployment create \
--resource-group viki-deploy-test-rg \
--template-file ./azureDeploy.json \
--parameters @viki-param.json \
--mode Incremental
```
