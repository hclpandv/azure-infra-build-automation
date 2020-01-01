<# 
 .Synopsis
  Get Access Token.

 .Description
  This function will get Access Token from Microsoft API.
  Downloaded from : https://github.com/rahilmaknojia/Azure-RESTApi-PowerShell/blob/master/Module/Utility/Utility.psm1

 .Example
   Get-AccessToken -GrantType "client_credentials" -ClientId <Client ID> -ClientSecret <Client Secret> -Resource "Resource URL or name" -ApiUri <URL to get Access token>
#>
Function Get-AccessToken
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Provide value to grant_type.')]
            [ValidateSet("client_credentials")]
            [string]$GrantType,
        [Parameter(Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Provide Client Id or Application Id from Azure AD or any Microsoft API.')]
            [string]$ClientId,
        [Parameter(Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Provide Client Secret provided from Azure AD or any Microsoft API.')]
            [string]$ClientSecret,
        [Parameter(Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Provide Resource url or name to access.')]
            [string]$Resource = "https://management.core.windows.net/",
        [Parameter(Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Provide Microsoft Azure API Login URL.')]
            [string]$ApiUri
    )

    $body = "grant_type=$GrantType&client_id=$ClientId&client_secret=$ClientSecret&resource=$Resource"

    $response = Invoke-RestMethod -Method Post -Uri $ApiUri -Body $body -ContentType 'application/x-www-form-urlencoded'

    return $response
}
