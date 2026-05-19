import os
import boto3
from dotenv import load_dotenv

load_dotenv()


def upload_file(file_path: str, key: str) -> str:
    bucket = os.getenv("S3_BUCKET")
    if not bucket:
        raise ValueError("S3_BUCKET is not set in environment variables.")

    print(f"[s3] Uploading '{file_path}' to s3://{bucket}/{key} ...")
    client = boto3.client("s3")
    client.upload_file(file_path, bucket, key)
    s3_uri = f"s3://{bucket}/{key}"
    print(f"[s3] Upload complete: {s3_uri}")
    return s3_uri
