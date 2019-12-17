provider "aws" {
  region = var.region
}

# I changed the machine type from m4.large to t2.small
# I changed the setting for encryped_at_rest from true to false
# I changed the number of worker nodes in the cluster from 3 to 1

resource "aws_kms_key" "a" {
  description             = "KMS key 1"
  deletion_window_in_days = 10
}

resource "aws_elasticsearch_domain" "example" {
  domain_name           = "example"
  elasticsearch_version = "2.3"

  cluster_config {
    instance_type  = "m4.large.elasticsearch"
    instance_count = 3
  }
  encrypt_at_rest {
    enabled    = true
    kms_key_id = aws_kms_key.a.key_id
  }

  tags = {
    Domain = "orlando-test"
  }
}

resource "aws_elasticsearch_domain_policy" "main" {
  domain_name = aws_elasticsearch_domain.example.domain_name

  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Condition": {
                "IpAddress": {"aws:SourceIp": "127.0.0.1/32"}
            },
            "Resource": "${aws_elasticsearch_domain.example.arn}/*"
        }
    ]
}
POLICIES
}