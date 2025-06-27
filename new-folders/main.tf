module "confluent_env_module" {
  source           = "./modules/confluent_environment" 
  environment_name = var.environment_display_name   
  confluent_api_key    = var.confluent_cloud_api_key
  confluent_api_secret = var.confluent_cloud_api_secret 
}

module "kafka_clusters" {
  for_each = toset(var.catalog_types)

  source           = "./modules/kafka_clusters"
  environment_id   = module.confluent_env_module.environment_id
  cluster_name    = each.key
  aws_region          = var.aws_region
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