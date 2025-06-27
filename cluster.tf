resource "confluent_kafka_cluster" "glue-kafka-cluster" {
    count = contains(var.catalog_types, "glue") || contains(var.catalog_types, "all") ? 1 : 0
    display_name = "Glue Kafka Cluster"
    availability = "SINGLE_ZONE"
    cloud        = "AWS"
    region       = var.aws_region
    standard {}

    environment {
        id = confluent_environment.my_environment.id
    }

    lifecycle {
        prevent_destroy = false
    }
}

resource "confluent_kafka_cluster" "snowflake-kafka-cluster" {
    count = contains(var.catalog_types, "snowflake") || contains(var.catalog_types, "all") ? 1 : 0
    display_name = "Snowflake Kafka Cluster"
    availability = "SINGLE_ZONE"
    cloud        = "AWS"
    region       = var.aws_region
    standard {}

    environment {
        id = confluent_environment.my_environment.id
    }

    lifecycle {
        prevent_destroy = false
    }
}

resource "confluent_kafka_cluster" "databricks-kafka-cluster" {
    count = contains(var.catalog_types, "databricks") || contains(var.catalog_types, "all") ? 1 : 0
    display_name = "Databricks Kafka Cluster"
    availability = "SINGLE_ZONE"
    cloud        = "AWS"
    region       = var.aws_region
    standard {}

    environment {
        id = confluent_environment.my_environment.id
    }

    lifecycle {
        prevent_destroy = false
    }
}
