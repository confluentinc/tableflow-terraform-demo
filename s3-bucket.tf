resource "random_integer" "bucket_suffix" {
    min = 1000
    max = 9999
}

resource "aws_s3_bucket" "my_bucket" {
    bucket = "cflt-tflow-${random_integer.bucket_suffix.result}"

    tags = {
        Name = "cflt-tflow-${random_integer.bucket_suffix.result}"
    }
    force_destroy = true
}