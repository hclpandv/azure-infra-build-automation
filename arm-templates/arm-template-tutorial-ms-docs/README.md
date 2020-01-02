### Tutorial: Create and deploy your first Azure Resource Manager template  

https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-tutorial-create-first-template?tabs=azure-powershell

* Tutorial followed as it is..
* Please observe commit messages to see the changes in each iteration


#### Commandline to develope and deploy ARM templates in incremental mode

* Better suited for agile developement

```bash
az group deployment create \
--Name addoutputs \
--resource-group viki-deploy-test-rg \
--template-file ./azureDeploy.json \
--parameters @viki-param.json \
--mode Incremental
```

* How parameters showup in shell

![image](https://user-images.githubusercontent.com/13016162/71651354-e3bb0f00-2d42-11ea-9900-9e6f9f772e69.png)
