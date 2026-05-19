import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()


def fetch_data(query: str = "SELECT * FROM records LIMIT 100") -> pd.DataFrame:
    rds_url = os.getenv("RDS_URL")
    if not rds_url:
        raise ValueError("RDS_URL is not set in environment variables.")

    print(f"[db] Connecting to RDS...")
    engine = create_engine(rds_url)

    with engine.connect() as conn:
        print(f"[db] Executing query: {query}")
        df = pd.read_sql(text(query), conn)

    print(f"[db] Fetched {len(df)} rows.")
    return df
