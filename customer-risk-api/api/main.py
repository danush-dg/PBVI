import os
from pathlib import Path
from typing import List

import psycopg2
from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.responses import HTMLResponse, JSONResponse
from pydantic import BaseModel, ConfigDict

app = FastAPI()


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    return JSONResponse(status_code=500, content={"detail": "Internal server error"})


STATIC_DIR = Path(__file__).parent / "static"

SQL_GET_CUSTOMER = (
    "SELECT customer_id, risk_tier, risk_factors"
    " FROM customer_risk_profiles WHERE customer_id = %s"
)


class CustomerResponse(BaseModel):
    model_config = ConfigDict(extra="forbid")
    customer_id: str
    risk_tier: str
    risk_factors: List[str]


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


@app.get("/customers/{customer_id}", response_model=CustomerResponse)
def get_customer(customer_id: str, _: None = Depends(verify_api_key)):
    conn = None
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            cur.execute(SQL_GET_CUSTOMER, (customer_id,))
            row = cur.fetchone()
        if row is None:
            raise HTTPException(status_code=404, detail="Customer not found")
        return CustomerResponse(
            customer_id=row[0],
            risk_tier=row[1],
            risk_factors=row[2],
        )
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=500, detail="Internal server error")
    finally:
        if conn is not None:
            conn.close()


@app.get("/", response_class=HTMLResponse)
def index():
    html = (STATIC_DIR / "index.html").read_text()
    return html.replace("{{API_KEY}}", os.environ.get("API_KEY", ""), 1)
