resource "azurerm_databricks_access_connector" "this" {
  name                = "tableflow-access-connector-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.region

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "blob_data_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "queue_data_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_databricks_access_connector.this.identity[0].principal_id
}

# Wait for Azure AD to propagate the access connector identity and role assignments
# Databricks needs time to discover the access connector before it can be used as a storage credential
resource "time_sleep" "wait_for_propagation" {
  create_duration = "120s"

  triggers = {
    access_connector_id = azurerm_databricks_access_connector.this.id
    blob_role           = azurerm_role_assignment.blob_data_contributor.id
    queue_role          = azurerm_role_assignment.queue_data_contributor.id
  }

  depends_on = [
    azurerm_role_assignment.blob_data_contributor,
    azurerm_role_assignment.queue_data_contributor
  ]
}
