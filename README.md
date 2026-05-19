# rds-llm-s3-test

A simple Python pipeline that:
1. Connects to an AWS RDS PostgreSQL database
2. Extracts data as a DataFrame
3. Optionally enriches each row using an LLM (OpenAI)
4. Exports the result as CSV
5. Uploads the CSV to an S3 bucket

---

## Project Structure

```
rds-llm-s3-test/
├── main.py          # Pipeline entry point
├── db.py            # RDS connection + data fetch
├── llm.py           # LLM enrichment (with mock fallback)
├── s3.py            # S3 upload helper
├── requirements.txt
├── .env.example     # Environment variable template
└── README.md
```

---

## Installation

```bash
# Clone / navigate to the project folder
cd rds-llm-s3-test

# Create a virtual environment
python -m venv .venv
source .venv/bin/activate      # macOS/Linux
.venv\Scripts\activate         # Windows

# Install dependencies
pip install -r requirements.txt
```

---

## Configuration

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

| Variable        | Required | Description |
|-----------------|----------|-------------|
| `RDS_URL`       | Yes      | SQLAlchemy connection string, e.g. `postgresql+psycopg2://user:pass@host:5432/mydb` |
| `S3_BUCKET`     | Yes      | Name of the target S3 bucket |
| `OPENAI_API_KEY`| No       | If absent, the LLM step runs in **mock mode** (no API calls) |
| `OUTPUT_PATH`   | No       | Local path for the CSV output (default: `./output.csv`) |

### AWS Credentials

The pipeline uses `boto3` and resolves credentials from the standard AWS chain:
- Environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- `~/.aws/credentials`
- IAM instance role (if running on EC2)

---

## Running the Pipeline

```bash
python main.py
```

Expected output:

```
[pipeline] Step 1 — Fetching data from RDS...
[db] Connecting to RDS...
[db] Executing query: SELECT * FROM records LIMIT 100
[db] Fetched 42 rows.
[pipeline] Step 2 — Enriching rows with LLM...
[pipeline]   Processing row 1/42...
...
[pipeline] Step 3 — Exporting CSV to './output.csv'...
[pipeline] CSV written: 42 rows.
[pipeline] Step 4 — Uploading to S3...
[s3] Uploading './output.csv' to s3://my-bucket/exports/output.csv ...
[s3] Upload complete: s3://my-bucket/exports/output.csv
[pipeline] Done. File available at: s3://my-bucket/exports/output.csv
```

---

## Custom Query

To run a different SQL query, edit the call in `main.py`:

```python
run_pipeline(query="SELECT id, name, created_at FROM customers WHERE active = true")
```

---

## LLM Fallback Mode

If `OPENAI_API_KEY` is not set (or the API call fails), `llm.py` returns a mock response:

```json
{
  "category": "unknown",
  "score_quality": 0.5,
  "note": "mock — OPENAI_API_KEY not set"
}
```

The pipeline always completes regardless of LLM availability.

---

## Output Format

The final CSV contains all original columns from RDS plus two enrichment columns:

| original columns... | category | score_quality |
|---------------------|----------|---------------|
| ...                 | billing  | 0.87          |
