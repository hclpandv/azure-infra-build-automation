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
elif
  echo file .env_azure must exist here, exiting
  exit 1
fi

# Login to Azure using service principal
az login --service-principal -u $ARM_APP_URL -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# Manage Azure Resources
az group list --output table

az group create --location westus --name created-using-service-principal-az-cli-rg
