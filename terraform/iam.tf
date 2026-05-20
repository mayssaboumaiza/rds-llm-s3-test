resource "aws_iam_role" "app" {
  name = "${var.project_name}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-app-role"
    Environment = var.environment
  }
}

resource "aws_iam_policy" "s3_exports" {
  name        = "${var.project_name}-s3-exports-policy"
  description = "Read/write access to the CSV exports bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.exports.arn,
          "${aws_s3_bucket.exports.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_read" {
  name        = "${var.project_name}-secrets-read-policy"
  description = "Read RDS_URL secret from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.rds_url.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_exports" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.s3_exports.arn
}

resource "aws_iam_role_policy_attachment" "secrets_read" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.secrets_read.arn
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-app-instance-profile"
  role = aws_iam_role.app.name
}
