import os
import json
from dotenv import load_dotenv

load_dotenv()


def _mock_enrich(row: dict) -> str:
    return json.dumps({
        "category": "unknown",
        "score_quality": 0.5,
        "note": "mock — OPENAI_API_KEY not set"
    })


def enrich_row(row: dict) -> str:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("[llm] No OPENAI_API_KEY found, using mock response.")
        return _mock_enrich(row)

    try:
        from openai import OpenAI
        client = OpenAI(api_key=api_key)

        prompt = (
            "You are a data analyst. Given the following record, return a JSON object "
            "with two fields: 'category' (a short category string) and 'score_quality' "
            "(a float between 0 and 1 representing the data quality).\n\n"
            f"Record: {json.dumps(row, default=str)}\n\n"
            "Respond ONLY with valid JSON."
        )

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.2,
            max_tokens=100,
        )

        content = response.choices[0].message.content.strip()
        json.loads(content)  # validate JSON before returning
        return content

    except Exception as e:
        print(f"[llm] LLM call failed ({e}), falling back to mock.")
        return _mock_enrich(row)
