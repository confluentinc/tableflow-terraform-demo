# Cloud-aware locals
locals {
  # Backward compatibility: use aws_region if specified, otherwise use region
  effective_region = var.aws_region != null ? var.aws_region : var.region

  # Cloud provider flags
  is_aws   = var.cloud_provider == "aws"
  is_azure = var.cloud_provider == "azure"
}

module "confluent_env_module" {
  source               = "./modules/confluent_environment"
  environment_name     = var.environment_display_name
  confluent_api_key    = var.confluent_cloud_api_key
  confluent_api_secret = var.confluent_cloud_api_secret

}

module "kafka_clusters" {
  for_each           = toset(var.catalog_types)
  source             = "./modules/kafka_clusters"
  cluster_name       = each.key
  cloud_provider     = var.cloud_provider
  region             = local.effective_region
  environment_id     = module.confluent_env_module.environment_id
  service_account_id = confluent_service_account.my_service_account.id

}

data "confluent_schema_registry_cluster" "essentials" {
  environment {
    id = module.confluent_env_module.environment_id
  }
  depends_on = [module.kafka_clusters]
}


module "api_keys" {
  for_each = module.kafka_clusters

  source                      = "./modules/api_keys"
  service_account_id          = confluent_service_account.my_service_account.id
  service_account_api_version = confluent_service_account.my_service_account.api_version
  service_account_kind        = confluent_service_account.my_service_account.kind
  kafka_cluster_id            = each.value.cluster_id
  kafka_api_version           = each.value.api_version
  kafka_cluster_kind          = each.value.kind
  environment_id              = module.confluent_env_module.environment_id

  depends_on = [confluent_role_binding.cluster_admin]

}

module "kafka_acls" {
  for_each           = module.kafka_clusters
  source             = "./modules/kafka_acls"
  kafka_cluster_id   = each.value.cluster_id
  service_account_id = confluent_service_account.my_service_account.id
  rest_endpoint      = each.value.rest_endpoint
  api_key            = module.api_keys[each.key].api_key
  api_secret         = module.api_keys[each.key].api_secret

  depends_on = [module.api_keys]
}

module "kafka_topic_stock_trades" {
  for_each      = module.kafka_clusters
  source        = "./modules/kafka_topic"
  topic_name    = "stock_trades"
  cluster_id    = each.value.cluster_id
  rest_endpoint = each.value.rest_endpoint
  api_key       = module.api_keys[each.key].api_key
  api_secret    = module.api_keys[each.key].api_secret

}


module "kafka_topic_users" {
  for_each      = module.kafka_clusters
  source        = "./modules/kafka_topic"
  topic_name    = "users"
  cluster_id    = each.value.cluster_id
  rest_endpoint = each.value.rest_endpoint
  api_key       = module.api_keys[each.key].api_key
  api_secret    = module.api_keys[each.key].api_secret

}

module "schema_registry_api_keys" {
  source                      = "./modules/schema_registry_api_keys"
  service_account_id          = confluent_service_account.my_service_account.id
  service_account_api_version = confluent_service_account.my_service_account.api_version
  service_account_kind        = confluent_service_account.my_service_account.kind
  environment_id              = module.confluent_env_module.environment_id
  depends_on                  = [module.kafka_clusters]
}


# create schema registry here
module "schema_registry" {
  source                     = "./modules/schema_registry"
  environment_id             = module.confluent_env_module.environment_id
  schema_registry_api_key    = module.schema_registry_api_keys.api_key
  schema_registry_api_secret = module.schema_registry_api_keys.api_secret
  stock_topic_name           = "stock_trades"
  users_topic_name           = "users"
  depends_on = [confluent_role_binding.all_topics_admin, confluent_role_binding.environment_admin,
  module.kafka_topic_stock_trades, module.kafka_topic_users, module.api_keys]
}


module "datagen_stock_trades" {
  for_each           = module.kafka_clusters
  source             = "./modules/datagen"
  environment_id     = module.confluent_env_module.environment_id
  kafka_cluster_id   = each.value.cluster_id
  service_account_id = confluent_service_account.my_service_account.id
  topic_name         = module.kafka_topic_stock_trades[each.key].topic_name
  output_data_format = "AVRO"
  quickstart         = "STOCK_TRADES"
  connector_name     = "datagen_stock_trades_${each.key}"
  tasks_max          = "1"
  max_interval       = "10"
  config_sensitive   = {}

}

module "datagen_users" {
  for_each           = module.kafka_clusters
  source             = "./modules/datagen"
  environment_id     = module.confluent_env_module.environment_id
  kafka_cluster_id   = each.value.cluster_id
  service_account_id = confluent_service_account.my_service_account.id
  topic_name         = module.kafka_topic_users[each.key].topic_name
  output_data_format = "AVRO"
  quickstart         = "USERS"
  connector_name     = "datagen_users_${each.key}"
  tasks_max          = "1"
  max_interval       = "10"
  config_sensitive   = {}

}


# AWS S3 Buckets (conditional - only for AWS)
module "aws_s3_bucket" {
  for_each      = local.is_aws ? module.kafka_clusters : {}
  source        = "./modules/aws_s3_bucket"
  provider_name = each.key
  bucket_suffix = random_integer.suffix.result
}

# Azure ADLS Containers (conditional - only for Azure)
module "azure_adls_container" {
  for_each               = local.is_azure ? module.kafka_clusters : {}
  source                 = "./modules/azure_adls_container"
  catalog_name           = each.key
  resource_group_name    = var.azure_resource_group_name
  region                 = local.effective_region
  storage_account_prefix = var.azure_storage_account_name_prefix
  random_suffix          = random_integer.suffix.result
}


locals {
  # Storage resource names (S3 bucket or ADLS container)
  storage_names = {
    for k in keys(module.kafka_clusters) :
    k => local.is_aws ? module.aws_s3_bucket[k].bucket_name : module.azure_adls_container[k].container_name
  }

  # Storage account names (Azure only)
  storage_account_names = {
    for k in keys(module.kafka_clusters) :
    k => local.is_azure ? module.azure_adls_container[k].storage_account_name : null
  }

  # AWS IAM role names
  iam_role_names = {
    for k in keys(module.kafka_clusters) :
    k => "tableflow-role-${k}-${random_integer.suffix.result}"
  }

  # AWS IAM role ARNs
  customer_s3_access_role_arns = local.is_aws ? {
    for k in keys(module.kafka_clusters) :
    k => "arn:aws:iam::${data.aws_caller_identity.current[0].account_id}:role/${local.iam_role_names[k]}"
  } : {}
}

module "provider_integration" {
  for_each       = module.kafka_clusters
  source         = "./modules/provider_integration"
  environment_id = module.confluent_env_module.environment_id
  provider_name  = each.key
  cloud_provider = var.cloud_provider

  # AWS-specific
  customer_role_arn = local.is_aws ? local.customer_s3_access_role_arns[each.key] : null

  # Azure-specific
  azure_tenant_id = local.is_azure ? var.azure_tenant_id : null

  depends_on = [
    module.confluent_env_module,
    module.aws_s3_bucket,
    module.azure_adls_container,
    module.kafka_clusters
  ]
}

# AWS IAM Roles (conditional - only for AWS)
module "aws_iam_role" {
  for_each                         = local.is_aws ? module.kafka_clusters : {}
  source                           = "./modules/aws_iam_role"
  customer_role_name               = local.iam_role_names[each.key]
  s3_bucket_name                   = module.aws_s3_bucket[each.key].bucket_name
  provider_integration_role_arn    = module.provider_integration[each.key].provider_integration_role_arn
  provider_integration_external_id = module.provider_integration[each.key].provider_integration_external_id
  provider_type                    = each.key
  random_suffix                    = random_integer.suffix.result
  aws_account_id                   = data.aws_caller_identity.current[0].account_id
  databricks_account_id            = contains(var.catalog_types, "databricks") ? var.databricks_account_id : null
}

# Azure Service Principals (conditional - only for Azure)
# Creates service principal for Confluent's multi-tenant application
module "azure_service_principal" {
  for_each                       = local.is_azure ? module.kafka_clusters : {}
  source                         = "./modules/azure_service_principal"
  catalog_name                   = each.key
  storage_account_id             = module.azure_adls_container[each.key].storage_account_id
  confluent_multi_tenant_app_id  = module.provider_integration[each.key].azure_confluent_multi_tenant_app_id

  depends_on = [
    module.provider_integration
  ]
}

# Azure Confluent Multi-Tenant Service Principal Permissions (conditional - only for Azure)
# Grants Confluent service principal permissions to access storage
module "azure_confluent_sp_permissions" {
  for_each                                = local.is_azure ? module.kafka_clusters : {}
  source                                  = "./modules/azure_confluent_sp_permissions"
  confluent_service_principal_object_id   = module.azure_service_principal[each.key].confluent_service_principal_object_id
  storage_account_id                      = module.azure_adls_container[each.key].storage_account_id
  resource_group_id                       = module.azure_adls_container[each.key].resource_group_id

  depends_on = [
    module.provider_integration,
    module.azure_adls_container,
    module.azure_service_principal
  ]
}


# create tableflow api key
module "tableflow_api_key" {
  source                      = "./modules/tableflow_api_key"
  environment_id              = module.confluent_env_module.environment_id
  service_account_id          = confluent_service_account.my_service_account.id
  service_account_api_version = confluent_service_account.my_service_account.api_version
  service_account_kind        = confluent_service_account.my_service_account.kind

}

# tableflow for stock_trades topic only
module "tableflow_stock_trades" {
  for_each                   = module.kafka_clusters
  source                     = "./modules/tableflow"
  environment_id             = module.confluent_env_module.environment_id
  kafka_cluster_id           = each.value.cluster_id
  topic_name                 = module.kafka_topic_stock_trades[each.key].topic_name
  catalog_type               = each.key
  cloud_provider             = var.cloud_provider
  storage_location_name      = local.storage_names[each.key]
  azure_storage_account_name = local.is_azure ? local.storage_account_names[each.key] : null
  provider_integration_id    = module.provider_integration[each.key].provider_integration_internal_id
  api_key                    = module.tableflow_api_key.api_key
  api_secret                 = module.tableflow_api_key.api_secret

  depends_on = [
    module.aws_iam_role,
    module.azure_service_principal,
    module.azure_confluent_sp_permissions,
    module.kafka_topic_stock_trades,
    module.tableflow_api_key,
    data.confluent_schema_registry_cluster.essentials,
    module.datagen_stock_trades,
    module.provider_integration
  ]
}

# Glue catalog integration (only if "glue" is in catalog_types AND cloud_provider is AWS)
module "glue_catalog_integration" {
  count = local.is_aws && contains(var.catalog_types, "glue") ? 1 : 0

  source                           = "./modules/glue_catalog_integration"
  environment_id                   = module.confluent_env_module.environment_id
  catalog_type                     = "glue"
  cluster_id                       = module.kafka_clusters["glue"].cluster_id
  provider_integration_internal_id = module.provider_integration["glue"].provider_integration_internal_id
  tableflow_api_key                = module.tableflow_api_key.api_key
  tableflow_api_secret             = module.tableflow_api_key.api_secret
}

# Microsoft Fabric catalog integration (only if "fabric" is in catalog_types AND cloud_provider is Azure)
module "fabric_catalog_integration" {
  count = local.is_azure && contains(var.catalog_types, "fabric") ? 1 : 0

  source                           = "./modules/fabric_catalog_integration"
  environment_id                   = module.confluent_env_module.environment_id
  catalog_type                     = "fabric"
  cluster_id                       = module.kafka_clusters["fabric"].cluster_id
  provider_integration_internal_id = module.provider_integration["fabric"].provider_integration_internal_id
  tableflow_api_key                = module.tableflow_api_key.api_key
  tableflow_api_secret             = module.tableflow_api_key.api_secret
  azure_tenant_id                  = var.azure_tenant_id
}

# catalog integration (only if "snowflake" is in catalog_types)
module "snowflake_catalog_integration" {
  count = contains(var.catalog_types, "snowflake") ? 1 : 0

  source = "./modules/snowflake_catalog_integration"

  environment_id          = module.confluent_env_module.environment_id
  kafka_cluster_id        = module.kafka_clusters["snowflake"].cluster_id
  snowflake_endpoint      = var.snowflake_endpoint
  snowflake_warehouse     = var.snowflake_warehouse
  snowflake_allowed_scope = var.snowflake_allowed_scope
  polaris_client_id       = var.polaris_client_id
  polaris_client_secret   = var.polaris_client_secret
  tableflow_api_key       = module.tableflow_api_key.api_key
  tableflow_api_secret    = module.tableflow_api_key.api_secret
}

module "flink_compute_pool" {
  for_each       = module.kafka_clusters
  source         = "./modules/flink_compute_pool"
  environment_id = module.confluent_env_module.environment_id
  display_name   = "flink-compute-pool-${each.key}"
  depends_on     = [module.kafka_clusters, module.api_keys]
}

module "databricks_external_table" {
  count = contains(var.catalog_types, "databricks") ? 1 : 0

  source                  = "./modules/databricks_external_table"
  storage_credential_name = "tableflow-external-credential-${random_integer.suffix.result}"
  cloud_provider          = var.cloud_provider

  # AWS-specific variables
  aws_iam_role_arn         = local.is_aws ? module.aws_iam_role["databricks"].role_arn : null
  iam_role_id              = local.is_aws ? module.aws_iam_role["databricks"].role_id : ""
  iam_policy_id            = local.is_aws ? module.aws_iam_role["databricks"].policy_id : ""
  iam_policy_attachment_id = local.is_aws ? module.aws_iam_role["databricks"].iam_policy_attachment_id : ""

  # Azure-specific variables
  azure_tenant_id      = local.is_azure ? var.azure_tenant_id : null
  azure_application_id = local.is_azure ? module.azure_service_principal["databricks"].databricks_client_id : null
  azure_client_secret  = local.is_azure ? module.azure_service_principal["databricks"].databricks_client_secret : null
  container_name       = local.is_azure ? local.storage_names["databricks"] : null
  storage_account_name = local.is_azure ? local.storage_account_names["databricks"] : null

  external_location_name    = "tableflow-external-location-${random_integer.suffix.result}"
  storage_location_name     = local.storage_names["databricks"]
  catalog_type              = "databricks"
  grant_principal           = var.databricks_client_id
  shared_dir_path           = "/Workspace/Users/${data.databricks_current_user.current_principal_from_workspace_provider[0].user_name}/Queries"
  sql_warehouse_id          = data.databricks_sql_warehouse.my_existing_warehouse[0].id
  query_display_name        = "Tableflow External Table Query ${random_integer.suffix.result}"
  databricks_host           = var.databricks_host
  databricks_token          = var.databricks_token
  confluent_organization_id = data.confluent_organization.current.id
  confluent_environment_id  = module.confluent_env_module.environment_id
  confluent_cluster_id      = module.kafka_clusters["databricks"].cluster_id
  kafka_topic_id            = module.kafka_topic_stock_trades["databricks"].topic_id
  random_suffix             = random_integer.suffix.result

  depends_on = [
    module.aws_iam_role,
    module.azure_service_principal,
    module.aws_s3_bucket,
    module.azure_adls_container,
    module.datagen_stock_trades["databricks"],
    module.datagen_users["databricks"]
  ]
}
