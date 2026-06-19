# Customer Risk API

A read-only authenticated lookup service that returns pre-assessed customer risk
tier and risk factors from a PostgreSQL database.

---

## Overview

The Customer Risk API lets operations staff retrieve accurate risk data for any
customer through a browser UI or any HTTP client. A single API key protects all
customer-data endpoints. The stack starts with one command and requires no setup
beyond copying an environment file.

**What it does:**
- Returns the stored `risk_tier` and `risk_factors` for a given `customer_id`
- Serves a browser UI for interactive lookups
- Enforces API-key authentication on every customer-data request

**What it does not do:**
- Calculate, modify, or write risk data
- Make external network calls
- Expose any database or infrastructure detail in responses

---

## Prerequisites

| Tool | Minimum version |
|---|---|
| Docker | 24.x |
| Docker Compose | v2 (bundled with Docker Desktop) |

No other runtime (Python, Node, etc.) is required on the host machine.

---

## Setup

**1. Clone the repository and enter the project directory:**

```bash
git clone <repo-url>
cd customer-risk-api
```

**2. Copy the environment template:**

```bash
cp .env.example .env
```

**3. Fill in the required values in `.env`:**

| Variable | Purpose |
|---|---|
| `POSTGRES_USER` | PostgreSQL login username |
| `POSTGRES_PASSWORD` | PostgreSQL login password |
| `POSTGRES_DB` | Name of the database to create |
| `POSTGRES_HOST` | Hostname of the database service (use `db` inside Compose) |
| `POSTGRES_PORT` | Port the database listens on (default `5432`) |
| `API_KEY` | Secret key callers must supply in the `X-API-Key` header |

Choose a strong, random value for `API_KEY`. The API rejects every customer-data
request that does not present this exact value.

---

## Running the Stack

```bash
docker compose up
```

Compose builds the API image, starts PostgreSQL, waits for the database health
check to pass, then starts the API server. The first build takes longer because
it downloads base images and installs dependencies.

Once running:
- **Browser UI** → [http://localhost:8000](http://localhost:8000)
- **API base URL** → `http://localhost:8000`

To stop and remove containers (data is preserved in the Docker volume):

```bash
docker compose down
```

---

## API Reference

### GET /health

Returns service liveness. No authentication required.

**Request:**
```
GET /health
```

**Response 200:**
```json
{ "status": "ok" }
```

---

### GET /customers/{customer_id}

Returns the risk tier and risk factors for the given customer. Requires
authentication.

**Request:**
```
GET /customers/{customer_id}
X-API-Key: <your-api-key>
```

**Response 200:**
```json
{
  "customer_id": 1,
  "risk_tier": "HIGH",
  "risk_factors": ["late_payments", "high_utilization"]
}
```

`risk_tier` and `risk_factors` are returned exactly as stored in the database —
no transformation or reordering is applied.

**Response 401** — missing or incorrect `X-API-Key`:
```json
{ "detail": "Invalid API key" }
```

**Response 404** — no customer found for that ID:
```json
{ "detail": "Customer not found" }
```

**Response 500** — unexpected server-side error:
```json
{ "detail": "Internal server error" }
```

---

### GET /

Serves the browser UI. Open [http://localhost:8000](http://localhost:8000) in a
browser, enter the customer ID and API key, and click **Look up**.

---

## Running Tests

The test suite covers SQL-injection hardening and invariant verification.

**Unit / integration tests (run inside the repo):**

```bash
cd customer-risk-api/api
pip install -r requirements.txt
python -m pytest test_injection.py -v
```

**Invariant shell tests (requires the stack to be running):**

```bash
bash customer-risk-api/verification/test_invariants.sh
```

The invariant script checks authentication enforcement, data-fidelity rules,
and information-leakage controls against the live API.

---

## Known Limitations

- **Single shared API key** — all callers share one key; per-user revocation is
  not supported. Rotating the key requires updating `API_KEY` in `.env` and
  restarting the stack.

- **Database reset requires volume removal** — to wipe and re-seed the database,
  run:

  ```bash
  docker compose down -v
  docker compose up
  ```

  `docker compose down` alone stops containers but preserves the volume and its
  data.
