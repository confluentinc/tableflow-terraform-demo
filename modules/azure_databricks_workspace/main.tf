resource "azurerm_databricks_workspace" "this" {
  name                = "databricks-${var.workspace_name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.region
  sku                 = "premium" # Required for Unity Catalog

  # Note: network_security_group_rules_required is only for VNet-injected workspaces
  # Removed to allow simple workspace creation without VNet

  tags = {
    Environment = "Tableflow"
    ManagedBy   = "Terraform"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}
