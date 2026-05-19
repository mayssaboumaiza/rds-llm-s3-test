import json
import os
import pandas as pd
from dotenv import load_dotenv

from db import fetch_data
from llm import enrich_row
from s3 import upload_file

load_dotenv()

OUTPUT_PATH = os.getenv("OUTPUT_PATH", "./output.csv")


def run_pipeline(query: str = "SELECT * FROM records LIMIT 100") -> None:
    # 1. Fetch data from RDS
    print("[pipeline] Step 1 — Fetching data from RDS...")
    df = fetch_data(query)

    if df.empty:
        print("[pipeline] No data returned. Exiting.")
        return

    # 2. Enrich each row via LLM
    print("[pipeline] Step 2 — Enriching rows with LLM...")
    enrichments = []
    for i, row in enumerate(df.to_dict(orient="records")):
        print(f"[pipeline]   Processing row {i + 1}/{len(df)}...")
        result = enrich_row(row)
        try:
            parsed = json.loads(result)
        except json.JSONDecodeError:
            parsed = {"category": "error", "score_quality": 0.0}
        enrichments.append(parsed)

    enrichment_df = pd.DataFrame(enrichments)
    output_df = pd.concat([df.reset_index(drop=True), enrichment_df], axis=1)

    # 3. Export to CSV
    print(f"[pipeline] Step 3 — Exporting CSV to '{OUTPUT_PATH}'...")
    output_df.to_csv(OUTPUT_PATH, index=False)
    print(f"[pipeline] CSV written: {len(output_df)} rows.")

    # 4. Upload to S3
    print("[pipeline] Step 4 — Uploading to S3...")
    s3_key = f"exports/{os.path.basename(OUTPUT_PATH)}"
    uri = upload_file(OUTPUT_PATH, s3_key)
    print(f"[pipeline] Done. File available at: {uri}")


if __name__ == "__main__":
    run_pipeline()
