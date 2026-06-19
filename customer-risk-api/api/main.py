import os
from pathlib import Path

import psycopg2
from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.responses import HTMLResponse

app = FastAPI()

STATIC_DIR = Path(__file__).parent / "static"


async def verify_api_key(api_key: str = Header(None, alias="X-API-Key")):
    expected = os.environ.get("API_KEY")
    if not api_key or api_key != expected:
        raise HTTPException(status_code=401, detail="Invalid API key")


def get_db_connection():
    try:
        return psycopg2.connect(
            host=os.environ.get("POSTGRES_HOST"),
            port=os.environ.get("POSTGRES_PORT"),
            dbname=os.environ.get("POSTGRES_DB"),
            user=os.environ.get("POSTGRES_USER"),
            password=os.environ.get("POSTGRES_PASSWORD"),
        )
    except psycopg2.Error:
        raise RuntimeError("Database connection failed")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/customers/{customer_id}")
def get_customer(customer_id: str, _: None = Depends(verify_api_key)):
    return {"message": "placeholder"}


@app.get("/", response_class=HTMLResponse)
def index():
    return (STATIC_DIR / "index.html").read_text()
