resource "aws_sagemaker_notebook_instance" "sagemaker_notebook" {
  name                  = var.instance_name
  instance_type         = "ml.t3.medium" # hardcode to free tier
  role_arn              = aws_iam_role.sagemaker_role.arn
  #lifecycle_config_name = "${var.instance_name}-lifecycle-config"
}

resource "aws_iam_role" "sagemaker_role" {
  name = "${var.instance_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "sagemaker.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "sagemaker_policy" {
  role = aws_iam_role.sagemaker_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sagemaker:*",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "s3:*"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

#resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "lifecycle_configuration" {
#  name = "${var.instance_name}-lifecycle-config"
#  on_start = base64encode(<<-EOF
#!/bin/bash
#sudo -u ec2-user -i
#conda install -c conda-forge pyspark -y
#EOF
#  )
#}
