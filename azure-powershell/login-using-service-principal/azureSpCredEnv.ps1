<#
    This Script is to be dot-sourced into main script to provide
    secret access token to manage azure
#>

<#
OUTPUT : az ad sp credential reset --name VikiAzureApiUser
{
    "appId": "0667bcd8-f2c7-4786-b378-eae25d71cd26",
    "name": "VikiAzureApiUser",
    "password": "78a46755-72a2-426f-b456-5816e0d2a8d1",
    "tenant": "8a20ab7c-c446-459b-a3ca-e12579b61804"
}
NOTE : This Service Principal must be deleted before git push 
        Use gitignore for this file in production   
#>


$env:ARM_CLIENT_ID="0667bcd8-f2c7-4786-b378-eae25d71cd26"
#$env:ARM_CLIENT_CERTIFICATE_PATH="/path/to/my/client/certificate.pfx"
#$env:ARM_CLIENT_CERTIFICATE_PASSWORD="Pa55w0rd123"
$env:ARM_CLIENT_SECRET="78a46755-72a2-426f-b456-5816e0d2a8d1"
$env:ARM_SUBSCRIPTION_ID="e7691dac-480f-40ed-9270-3ab6eea695f7"
$env:ARM_TENANT_ID="8a20ab7c-c446-459b-a3ca-e12579b61804"
