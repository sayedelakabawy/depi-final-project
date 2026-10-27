"""Central configuration. All settings come from environment variables (.env)."""
import os
from dotenv import load_dotenv

load_dotenv()

POSTGRES = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "port": int(os.getenv("POSTGRES_PORT", 5432)),
    "dbname": os.getenv("POSTGRES_DB"),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD"),
}

INPUT_CSV_PATH = os.getenv("INPUT_CSV_PATH", "data/sample/feedback_sample.csv")
MODEL_ID = os.getenv("MODEL_ID")
INFERENCE_BATCH_SIZE = int(os.getenv("INFERENCE_BATCH_SIZE", 16))
MAX_TOKENS = int(os.getenv("MAX_TOKENS", 512))
MAX_RETRIES = int(os.getenv("MAX_RETRIES", 3))
