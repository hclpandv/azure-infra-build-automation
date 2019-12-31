## Login and Manage Azure Resources via service principal

1. Setup Environment Varibles

```bash
# Bash
export ARM_CLIENT_ID="0667bcd8-f2c7-4786-b378-eae25d71cd26"
#export ARM_CLIENT_CERTIFICATE_PATH="/path/to/my/client/certificate.pfx"
#export ARM_CLIENT_CERTIFICATE_PASSWORD="Pa55w0rd123"
export ARM_CLIENT_SECRET="78a46755-72a2-426f-b456-5816e0d2a8d1"
export ARM_SUBSCRIPTION_ID="e7691dac-480f-40ed-9270-3ab6eea695f7"
export ARM_TENANT_ID="8a20ab7c-c446-459b-a3ca-e12579b61804"
```

```Powershell
# Powershell
$env:ARM_CLIENT_ID="0667bcd8-f2c7-4786-b378-eae25d71cd26"
#$env:ARM_CLIENT_CERTIFICATE_PATH="/path/to/my/client/certificate.pfx"
#$env:ARM_CLIENT_CERTIFICATE_PASSWORD="Pa55w0rd123"
$env:ARM_CLIENT_SECRET="78a46755-72a2-426f-b456-5816e0d2a8d1"
$env:ARM_SUBSCRIPTION_ID="e7691dac-480f-40ed-9270-3ab6eea695f7"
$env:ARM_TENANT_ID="8a20ab7c-c446-459b-a3ca-e12579b61804"
```

2. Create a seperate script file to setup the env and then dot source it to main script

```
# Powershell
. azureSpCredEnv.ps1
# Bash
source azure-sp-cred.sh 
```

3. Use `gitignore` to prevent this file to check in to repo

