resource "aws_s3_bucket" "lb_logs" {
  bucket = "load-balancer-logs-${var.environment}-${var.name}"
  acl    = "log-delivery-write"
  region = "${var.region}"

  versioning {
    enabled = false
  }

  lifecycle_rule {
    id      = "log"
    prefix  = "log/"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::load-balancer-logs-${var.environment}-${var.name}/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY

  tags {
    Name        = "${var.environment}-${var.application}-${var.name}"
    Environment = "${var.environment}"
    Application = "${var.application}"
    cost_code   = "${var.cost_code}"
  }
}
