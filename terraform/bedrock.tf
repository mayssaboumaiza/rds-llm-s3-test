# AWS Bedrock — foundation model inference (LLM)
# Migré vers Azure OpenAI Service par le pipeline cloud-migrator

resource "aws_bedrock_foundation_model_agreement" "llm" {
  model_id = "anthropic.claude-3-sonnet-20240229-v1:0"
}

resource "aws_iam_role" "bedrock_exec" {
  name = "rds-llm-bedrock-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "bedrock.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}
