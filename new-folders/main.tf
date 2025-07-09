module "confluent_env_module" {
  source           = "./modules/confluent_environment" 
  environment_name = var.environment_display_name   
  confluent_api_key    = var.confluent_cloud_api_key
  confluent_api_secret = var.confluent_cloud_api_secret 

}

module "kafka_clusters" {
  for_each        = toset(var.catalog_types)
  source          = "./modules/kafka_clusters"
  cluster_name    = each.key
  aws_region      = var.aws_region
  environment_id  = module.confluent_env_module.environment_id
  service_account_id = confluent_service_account.my_service_account.id

}

data "confluent_schema_registry_cluster" "essentials" { 
  environment {
    id = module.confluent_env_module.environment_id
  }
    depends_on = [ module.kafka_clusters ]
}


module "api_keys" {
  for_each = module.kafka_clusters

  source                     = "./modules/api_keys"
  service_account_id         = confluent_service_account.my_service_account.id
  service_account_api_version = confluent_service_account.my_service_account.api_version
  service_account_kind       = confluent_service_account.my_service_account.kind
  kafka_cluster_id           = each.value.cluster_id
  kafka_api_version          = each.value.api_version
  kafka_cluster_kind         = each.value.kind
  environment_id             = module.confluent_env_module.environment_id

  depends_on = [ confluent_role_binding.cluster_admin ]
  
}

module "kafka_acls" {
  for_each           = module.kafka_clusters
  source             = "./modules/kafka_acls"
  kafka_cluster_id   = each.value.cluster_id
  service_account_id = confluent_service_account.my_service_account.id
  rest_endpoint      = each.value.rest_endpoint
  api_key            = module.api_keys[each.key].api_key
  api_secret         = module.api_keys[each.key].api_secret

  depends_on         = [module.api_keys]
}

module "kafka_topic_stock_trades" {
  for_each = module.kafka_clusters
  source           = "./modules/kafka_topic"
  topic_name       = "stock_trades"
  cluster_id       = each.value.cluster_id
  rest_endpoint    = each.value.rest_endpoint
  api_key          = module.api_keys[each.key].api_key
  api_secret       = module.api_keys[each.key].api_secret

}


module "kafka_topic_users" {
  for_each = module.kafka_clusters
  source           = "./modules/kafka_topic"
  topic_name       = "users"
  cluster_id       = each.value.cluster_id
  rest_endpoint    = each.value.rest_endpoint
  api_key          = module.api_keys[each.key].api_key
  api_secret       = module.api_keys[each.key].api_secret

}

module "schema_registry_api_keys" {
  source           = "./modules/schema_registry_api_keys"
  service_account_id = confluent_service_account.my_service_account.id
  service_account_api_version = confluent_service_account.my_service_account.api_version
  service_account_kind = confluent_service_account.my_service_account.kind
  environment_id   = module.confluent_env_module.environment_id
  depends_on = [ module.kafka_clusters ]
}


# create schema registry here
module "schema_registry" {
  source           = "./modules/schema_registry"
  environment_id   = module.confluent_env_module.environment_id
  schema_registry_api_key = module.schema_registry_api_keys.api_key
  schema_registry_api_secret = module.schema_registry_api_keys.api_secret
  stock_topic_name = "stock_trades"
  users_topic_name = "users"
  depends_on = [ confluent_role_binding.all_topics_admin, confluent_role_binding.environment_admin,
                  module.kafka_topic_stock_trades, module.kafka_topic_users, module.api_keys ]
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


module "aws_s3_bucket" {
  for_each     = module.kafka_clusters
  source       = "./modules/aws_s3_bucket"
  provider_name = each.key
  bucket_suffix = random_integer.suffix.result

}


locals {
  iam_role_names = {
    for k in keys(module.kafka_clusters) :
    k => "tableflow-role-${k}-${random_integer.suffix.result}"
  }
  customer_s3_access_role_arns = {
    for k in keys(module.kafka_clusters) :
    k => "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.iam_role_names[k]}"
  }
}

module "provider_integration" {
  for_each = module.kafka_clusters
  source   = "./modules/provider_integration"
  environment_id = module.confluent_env_module.environment_id
  provider_name        = each.key
  customer_role_arn    = local.customer_s3_access_role_arns[each.key]
  depends_on = [ module.confluent_env_module, module.aws_s3_bucket, module.kafka_clusters ]
}

module "aws_iam_role" {
  for_each                        = module.kafka_clusters
  source                          = "./modules/aws_iam_role"
  customer_role_name              = local.iam_role_names[each.key]
  s3_bucket_name                  = module.aws_s3_bucket[each.key].bucket_name
  provider_integration_role_arn   = module.provider_integration[each.key].provider_integration_role_arn
  provider_integration_external_id = module.provider_integration[each.key].provider_integration_external_id
  provider_type                   = each.key
  random_suffix                   = random_integer.suffix.result

}


# create tableflow api key
module "tableflow_api_key" {
  source           = "./modules/tableflow_api_key"
  environment_id   = module.confluent_env_module.environment_id
  service_account_id = confluent_service_account.my_service_account.id
  service_account_api_version = confluent_service_account.my_service_account.api_version
  service_account_kind = confluent_service_account.my_service_account.kind

}

# tableflow for stock_trades topic only
module "tableflow_stock_trades" {
  for_each                = module.kafka_clusters
  source                  = "./modules/tableflow"
  environment_id          = module.confluent_env_module.environment_id
  kafka_cluster_id        = each.value.cluster_id
  topic_name              = module.kafka_topic_stock_trades[each.key].topic_name
  catalog_type            = each.key
  s3_bucket_name          = module.aws_s3_bucket[each.key].bucket_name
  provider_integration_id = module.provider_integration[each.key].provider_integration_internal_id
  api_key                 = module.tableflow_api_key.api_key
  api_secret              = module.tableflow_api_key.api_secret

  depends_on              = [
    module.aws_iam_role,
    module.kafka_topic_stock_trades,
    module.tableflow_api_key,
    data.confluent_schema_registry_cluster.essentials,
    module.datagen_stock_trades,
    module.provider_integration
  ]
}

# catalog integration (only if "glue" is in catalog_types)
module "glue_catalog_integration" {
  count = contains(var.catalog_types, "glue") ? 1 : 0

  source = "./modules/glue_catalog_integration"
  environment_id = module.confluent_env_module.environment_id
  catalog_type = "glue"
  cluster_id = module.kafka_clusters["glue"].cluster_id
  provider_integration_internal_id = module.provider_integration["glue"].provider_integration_internal_id
  tableflow_api_key = module.tableflow_api_key.api_key
  tableflow_api_secret = module.tableflow_api_key.api_secret
}

# catalog integration (only if "snowflake" is in catalog_types)
module "snowflake_catalog_integration" {
  count = contains(var.catalog_types, "snowflake") ? 1 : 0

  source = "./modules/snowflake_catalog_integration"

  environment_id                   = module.confluent_env_module.environment_id
  kafka_cluster_id                 =  module.kafka_clusters["snowflake"].cluster_id
  snowflake_endpoint               = var.snowflake_endpoint
  snowflake_warehouse              = var.snowflake_warehouse
  snowflake_allowed_scope          = var.snowflake_allowed_scope
  polaris_client_id                = var.polaris_client_id
  polaris_client_secret            = var.polaris_client_secret
  tableflow_api_key = module.tableflow_api_key.api_key
  tableflow_api_secret = module.tableflow_api_key.api_secret
}