# AWS Bedrock — foundation model inference (LLM)
# Modele : Claude 3 Haiku (le moins cher, ideal pour les tests)
# ~$0.00025 / 1K input tokens

resource "aws_iam_role" "bedrock_exec" {
  name = "${var.project_name}-bedrock-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "bedrock.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "bedrock_invoke" {
  name = "bedrock-invoke-haiku"
  role = aws_iam_role.bedrock_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["bedrock:InvokeModel"]
      Resource = "arn:aws:bedrock:*::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
    }]
  })
}
