#!/bin/bash
# Commands to be run by Azure AD administrator

# For Fabric catalog integration
echo "Creating service principal for Confluent (Fabric)..."
az ad sp create --id f18138e0-9124-455f-a3fa-abc450f87ad0 || echo "SP may already exist"

# For Databricks catalog integration  
echo "Creating Azure AD application for Databricks..."
APP_ID=$(az ad app create --display-name "tableflow-databricks-app" --query appId -o tsv)
echo "Databricks App ID: $APP_ID"

# Create service principal for the Databricks app
az ad sp create --id $APP_ID

# Create client secret for Databricks app
SECRET=$(az ad app credential reset --id $APP_ID --append --query password -o tsv)
echo "Databricks Client Secret: $SECRET"

echo ""
echo "Save these values for terraform.tfvars:"
echo "  databricks_azure_app_id = \"$APP_ID\""
echo "  databricks_azure_client_secret = \"$SECRET\""
