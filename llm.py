import os
import json
import boto3
from dotenv import load_dotenv

load_dotenv()

# Claude 3 Haiku — modele Anthropic le moins cher sur Bedrock
# ~$0.00025 / 1K input tokens
_MODEL_ID = "anthropic.claude-3-haiku-20240307-v1:0"
_AWS_REGION = os.getenv("AWS_REGION", "us-east-1")


def _mock_enrich(row: dict) -> str:
    return json.dumps({
        "category": "unknown",
        "score_quality": 0.5,
        "note": "mock — AWS credentials not configured"
    })


def enrich_row(row: dict) -> str:
    try:
        client = boto3.client("bedrock-runtime", region_name=_AWS_REGION)

        prompt = (
            "You are a data analyst. Given the following record, return a JSON object "
            "with two fields: 'category' (a short category string) and 'score_quality' "
            "(a float between 0 and 1 representing the data quality).

"
            f"Record: {json.dumps(row, default=str)}

"
            "Respond ONLY with valid JSON."
        )

        body = json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 150,
            "temperature": 0.2,
            "messages": [{"role": "user", "content": prompt}],
        })

        response = client.invoke_model(
            modelId=_MODEL_ID,
            body=body,
            contentType="application/json",
            accept="application/json",
        )

        result = json.loads(response["body"].read())
        content = result["content"][0]["text"].strip()
        json.loads(content)  # valide JSON avant de retourner
        return content

    except Exception as e:
        print(f"[llm] Bedrock call failed ({e}), falling back to mock.")
        return _mock_enrich(row)
