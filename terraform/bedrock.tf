# AWS Bedrock — LLM inference endpoint
resource "aws_bedrock_model_invocation_logging_configuration" "main" {
  logging_config {
    embedding_data_delivery_enabled = true
    image_data_delivery_enabled     = true
    text_data_delivery_enabled      = true
    s3_config {
      bucket_name = aws_s3_bucket.exports.id
      key_prefix  = "bedrock-logs/"
    }
  }
}
