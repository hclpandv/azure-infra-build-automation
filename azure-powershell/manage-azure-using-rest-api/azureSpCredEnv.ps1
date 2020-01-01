<#
    This Script is to be dot-sourced into main script to provide
    secret access token to manage azure
#>

<#
OUTPUT: az ad sp create-for-rbac --name viki-api-app
Changing "viki-api-app" to a valid URI of "http://viki-api-app", which is the required format used for service principal names
Creating a role assignment under the scope of "/subscriptions/e7691dac-480f-40ed-9270-3ab6eea695f7"
{
  "appId": "8063d01f-3dc6-4b89-b58d-83e2e6245298",
  "displayName": "viki-api-app",
  "name": "http://viki-api-app",
  "password": "1210865e-a3c8-43ab-b240-1cec9476c415",
  "tenant": "8a20ab7c-c446-459b-a3ca-e12579b61804"
} 
#>


$env:ARM_CLIENT_ID="8063d01f-3dc6-4b89-b58d-83e2e6245298"
#$env:ARM_CLIENT_CERTIFICATE_PATH="/path/to/my/client/certificate.pfx"
#$env:ARM_CLIENT_CERTIFICATE_PASSWORD="Pa55w0rd123"
$env:ARM_CLIENT_SECRET="1210865e-a3c8-43ab-b240-1cec9476c415"
$env:ARM_SUBSCRIPTION_ID="e7691dac-480f-40ed-9270-3ab6eea695f7"
$env:ARM_TENANT_ID="8a20ab7c-c446-459b-a3ca-e12579b61804"
