#!/usr/bin/env bash

#
# Script uses Azure Service Principle to login to Azure
# and azure cli to manage azure resources
#

#--- Vars
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


#--- Main

# Load azure env file
if [[ -e $SCRIPT_DIR/.env_azure ]]; then
  source $SCRIPT_DIR/.env_azure
else
  echo file .env_azure must exist here, exiting
  exit 1
fi

# Use curl 
curl -X GET -H "Authorization: Bearer $AZURE_ACCESS_TOKEN" -H "Content-Type: application/json" https://management.azure.com/subscriptions/$ARM_SUBSCRIPTION_ID/resourcegroups\?api-version\=2017-05-10

# You can also use az cli to access api
# az rest -m get -u 'https://management.azure.com/subscriptions/${ARM_SUBSCRIPTION_ID}/providers/Microsoft.Web/sites?api-version=2017-05-10'
