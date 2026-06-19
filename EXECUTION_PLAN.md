# EXECUTION_PLAN.md — Customer Risk API

## Changelog
| Version | Date | Author | Change |
|---|---|---|---|
| v1.0 | 2026-06-19 | Engineer | Greenfield — Initial. Five sessions. |

---

## Project Stack
- Docker Compose · Postgres 15 · FastAPI (Python 3.11) · psycopg2 · Vanilla HTML/JS
- Auth: single shared API key via X-Api-Key header
- No ORM · No connection pool · No external calls

## GLOBAL Invariants (Claude.md Section 2)
INV-01 · INV-03 · INV-05 · INV-06 · INV-07

## Repository Structure
```
customer-risk-api/
├── docker-compose.yml
├── .env.example
├── db/
│   └── init.sql
├── api/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── main.py
└── static/
    └── index.html
```

---

## Session 1 — Project Scaffold and Database

**Goal:** Postgres running with correct schema and seed data. No application code.
**Branch:** session/s01_scaffold
**Verification state at close:** Direct psql query returns 9+ seed rows across all three tiers.

---

### Task 1.1 — Create the project directory structure

**CC Prompt:**
```
Create the following directory structure from the repo root.
All files must be empty placeholders — no content.

customer-risk-api/
├── docker-compose.yml
├── .env.example
├── db/
│   └── init.sql
├── api/
│   Dockerfile
│   requirements.txt
│   main.py
└── static/
    └── index.html

Do not create any other files or directories.
Do not write any content into any file.
```

**Test Cases:**
- TC-1: All 7 files exist at the correct paths
- TC-2: No additional files or directories are present beyond those listed

**Verification Command:**
```bash
find customer-risk-api -type f | sort
```

**Expected Output:**
```
customer-risk-api/.env.example
customer-risk-api/api/Dockerfile
customer-risk-api/api/main.py
customer-risk-api/api/requirements.txt
customer-risk-api/db/init.sql
customer-risk-api/docker-compose.yml
customer-risk-api/static/index.html
```

**Invariants touched:** None — structural scaffolding only.
**Regression classification:** NOT-REGRESSION-RELEVANT

---

### Task 1.2 — Write the database schema and seed data

**CC Prompt:**
```
Write db/init.sql.

Requirements:
1. Create a table named customer_risk_profiles with columns:
   - customer_id VARCHAR(50) PRIMARY KEY
   - risk_tier VARCHAR(10) NOT NULL CHECK (risk_tier IN ('LOW', 'MEDIUM', 'HIGH'))
   - risk_factors TEXT[] NOT NULL

2. Use CREATE TABLE IF NOT EXISTS.

3. Insert exactly 9 seed rows — 3 per tier (LOW, MEDIUM, HIGH).
   Customer IDs must follow the pattern CUST-001 through CUST-009.
   Each row must have at least 2 risk factors as a TEXT[] array.
   No row may have an empty risk_factors array.

4. The file must contain no UPDATE, DELETE, TRUNCATE, trigger definitions,
   or any DDL beyond the single CREATE TABLE statement.

Do not write any application code. Only db/init.sql.
```

**Test Cases:**
- TC-1: Table exists with correct column names and types after container start
- TC-2: CHECK constraint rejects INSERT with risk_tier = 'CRITICAL'
- TC-3: Exactly 3 rows with risk_tier = 'LOW', 3 with 'MEDIUM', 3 with 'HIGH'
- TC-4: No row has an empty risk_factors array
- TC-5: No UPDATE, DELETE, TRUNCATE, or trigger definition appears in init.sql

**Verification Command:**
```bash
docker compose exec db psql -U riskuser -d riskdb \
  -c "SELECT risk_tier, COUNT(*) FROM customer_risk_profiles GROUP BY risk_tier ORDER BY risk_tier;"
```

**Expected Output:**
```
 risk_tier | count
-----------+-------
 HIGH      |     3
 LOW       |     3
 MEDIUM    |     3
(3 rows)
```

**Supplementary verification — CHECK constraint:**
```bash
docker compose exec db psql -U riskuser -d riskdb \
  -c "INSERT INTO customer_risk_profiles VALUES ('TEST-999', 'CRITICAL', '{\"factor\"}');" 2>&1 | grep -i "violates"
```
Expected: output contains "violates check constraint"

**Supplementary verification — no write DDL in init.sql:**
```bash
grep -iE "(UPDATE|DELETE|TRUNCATE|CREATE TRIGGER|CREATE FUNCTION)" customer-risk-api/db/init.sql
```
Expected: no output (exit code 1 from grep means no match — this is a PASS)

**Invariants touched:** INV-03 (no write triggers in schema), INV-04b (CHECK constraint)
**Regression classification:** HARNESS-CANDIDATE (INV-03 schema check), REGRESSION-RELEVANT (seed data count)

---

### Task 1.3 — Write docker-compose.yml and .env.example

**CC Prompt:**
```
Write docker-compose.yml and .env.example.

docker-compose.yml requirements:
1. Two services: db and api.
2. db service:
   - Image: postgres:15
   - Environment variables sourced from .env: POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB
   - Volume mount: ./db/init.sql to /docker-entrypoint-initdb.d/init.sql
   - HEALTHCHECK using pg_isready: interval 5s, timeout 5s, retries 5
   - No external network definitions
3. api service:
   - Build context: ./api
   - Environment variables sourced from .env: POSTGRES_USER, POSTGRES_PASSWORD,
     POSTGRES_DB, POSTGRES_HOST=db, POSTGRES_PORT=5432, API_KEY
   - Ports: 8000:8000
   - depends_on: db with condition: service_healthy
   - No external network definitions
4. No networks: section defining external networks.

.env.example requirements:
- Six keys: POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB, POSTGRES_HOST, POSTGRES_PORT, API_KEY
- Placeholder values only — no real credentials

Do not write any application code. Only these two files.
```

**Test Cases:**
- TC-1: `docker compose config --quiet` exits 0 with no errors
- TC-2: db service has a HEALTHCHECK defined
- TC-3: api service has depends_on db with condition: service_healthy
- TC-4: No external network definitions in docker-compose.yml
- TC-5: All six keys present in .env.example

**Verification Command:**
```bash
cd customer-risk-api && docker compose config --quiet && echo "CONFIG VALID"
```
Expected: `CONFIG VALID` with no errors.

**Supplementary verification — no external networks:**
```bash
grep -i "external: true" customer-risk-api/docker-compose.yml
```
Expected: no output.

**Supplementary verification — six env keys:**
```bash
grep -c "=" customer-risk-api/.env.example
```
Expected: `6`

**Invariants touched:** INV-08 (no external network definitions), INV-11 (healthcheck + depends_on)
**Regression classification:** REGRESSION-RELEVANT

---

### Session 1 Integration Check

```bash
cd customer-risk-api
cp .env.example .env
# Edit .env to set real values before running
docker compose up db -d
sleep 8
docker compose exec db psql -U riskuser -d riskdb \
  -c "SELECT customer_id, risk_tier FROM customer_risk_profiles ORDER BY customer_id;"
```

Expected: 9 rows returned, all three tiers present, no errors.

---

## Session 2 — FastAPI Application Core

**Goal:** FastAPI container with database connection and API key authentication.
No customer lookup logic yet — skeleton, connection function, and auth dependency only.
**Branch:** session/s02_api_core
**Verification state at close:** API container starts, /health returns 200, unauthenticated
requests to /customers/{id} return 401.

---

### Task 2.1 — Write requirements.txt and Dockerfile

**CC Prompt:**
```
Write api/requirements.txt and api/Dockerfile.

requirements.txt must contain exactly these packages and no others:
  fastapi==0.110.0
  uvicorn==0.29.0
  psycopg2-binary==2.9.9

Dockerfile requirements:
- Base image: python:3.11-slim
- Working directory: /app
- Copy requirements.txt and install dependencies
- Copy application source
- Expose port 8000
- CMD: uvicorn main:app --host 0.0.0.0 --port 8000

Do not add any other packages or instructions.
```

**Test Cases:**
- TC-1: `docker compose build api` exits 0 with no errors
- TC-2: Built image contains exactly the three specified packages

**Verification Command:**
```bash
cd customer-risk-api && docker compose build api 2>&1 | tail -5
```
Expected: successful build message, no errors.

**Supplementary verification — package count:**
```bash
grep -c "==" customer-risk-api/api/requirements.txt
```
Expected: `3`

**Invariants touched:** None directly.
**Regression classification:** NOT-REGRESSION-RELEVANT

---

### Task 2.2 — Write the FastAPI application skeleton

**CC Prompt:**
```
Write api/main.py with a FastAPI application skeleton.

Requirements:
1. Create a FastAPI app instance.
2. Define exactly three routes:
   - GET /health — returns {"status": "ok"} with HTTP 200, no auth required
   - GET /customers/{customer_id} — returns {"message": "placeholder"} for now,
     auth required (dependency to be wired in Task 2.4)
   - GET / — returns the contents of static/index.html as an HTML response
3. No business logic in any route.
4. No database calls.
5. No auth logic — that comes in Task 2.4.
6. No additional imports beyond fastapi, os, and pathlib.
7. No middleware, background tasks, or lifespan events.

The static/index.html file will be at /app/static/index.html inside the container.
Use pathlib to construct the path relative to the main.py file location.
```

**Test Cases:**
- TC-1: GET /health returns 200 with body {"status": "ok"}
- TC-2: GET /customers/CUST-001 returns 200 with placeholder body (no auth yet)
- TC-3: Application starts without import errors

**Verification Command:**
```bash
docker compose up -d && sleep 3 && curl -s http://localhost:8000/health
```
Expected: `{"status":"ok"}`

**Invariants touched:** INV-05 (health check is the sole unauthenticated surface — verify
/health returns only {"status":"ok"} and no customer data)
**Regression classification:** REGRESSION-RELEVANT

---

### Task 2.3 — Write the database connection function

**CC Prompt:**
```
Add a database connection function to api/main.py.

Requirements:
1. Define a function get_db_connection() that:
   - Reads POSTGRES_HOST, POSTGRES_PORT, POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD
     from environment variables using os.environ.get()
   - Opens and returns a psycopg2 connection using these values
   - Does NOT use a connection pool
   - Does NOT hardcode any credentials
2. All psycopg2 exceptions raised during connection must be caught within the function
   and re-raised as a generic RuntimeError with the message "Database connection failed"
   — no psycopg2 exception detail may propagate out of this function.
3. Do not modify any existing route or import.
4. Do not call this function from any route yet.
```

**Test Cases:**
- TC-1: Function returns a valid psycopg2 connection when DB is running
- TC-2: Function raises RuntimeError (not psycopg2 exception) when DB is unreachable
- TC-3: No credentials appear in the RuntimeError message

**Verification Command:**
```bash
docker compose exec api python -c \
  "import main; conn = main.get_db_connection(); print('PASS' if conn else 'FAIL')"
```
Expected: `PASS`

**Supplementary verification — error wrapping:**
```bash
docker compose stop db && sleep 2 && \
docker compose exec api python -c \
  "import main
try:
    main.get_db_connection()
except RuntimeError as e:
    print('PASS:', str(e))
except Exception as e:
    print('FAIL — wrong exception type:', type(e).__name__, str(e))
" && docker compose start db
```
Expected: `PASS: Database connection failed`

**Invariants touched:** INV-07 (psycopg2 exceptions must not propagate out of this function)
**Regression classification:** REGRESSION-RELEVANT

---

### Task 2.4 — Write the API key authentication dependency

**CC Prompt:**
```
Add an API key authentication dependency to api/main.py and wire it to the
customer lookup route.

Requirements:
1. Define an async function verify_api_key(api_key: str = Header(None, alias="X-API-Key")):
   - Reads API_KEY from environment using os.environ.get("API_KEY")
   - If api_key is None, empty string, or does not match the environment value:
     raise HTTPException(status_code=401, detail="Invalid API key")
   - The detail string must be the static literal "Invalid API key"
     — no f-string, no format(), no interpolation of any kind
   - The submitted api_key value must not appear in the exception detail or anywhere
     in the function's output
2. Import Header and HTTPException from fastapi.
3. Wire verify_api_key as a dependency on GET /customers/{customer_id} only.
   GET /health must remain unauthenticated.
   GET / must remain unauthenticated.
4. Do not implement the customer lookup logic yet — the route still returns the placeholder.
```

**Test Cases:**
- TC-1: GET /customers/CUST-001 with no X-API-Key header returns 401 {"detail": "Invalid API key"}
- TC-2: GET /customers/CUST-001 with empty X-API-Key header returns 401 {"detail": "Invalid API key"}
- TC-3: GET /customers/CUST-001 with wrong key returns 401 {"detail": "Invalid API key"}
- TC-4: GET /customers/CUST-001 with correct key returns 200 (placeholder body)
- TC-5: GET /health with no key returns 200 {"status": "ok"}
- TC-6: 401 response body is exactly {"detail": "Invalid API key"} — no additional fields

**Verification Command:**
```bash
# Set TEST_KEY to the value in your .env API_KEY field
curl -s http://localhost:8000/customers/CUST-001
```
Expected: `{"detail":"Invalid API key"}`

**Supplementary verification — correct key accepted:**
```bash
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-001
```
Expected: placeholder 200 response (not 401)

**Supplementary verification — empty string key:**
```bash
curl -s -H "X-API-Key: " http://localhost:8000/customers/CUST-001
```
Expected: `{"detail":"Invalid API key"}`

**Supplementary verification — detail is static literal (no key echoing):**
```bash
curl -s -H "X-API-Key: INJECTED_TEST_VALUE" http://localhost:8000/customers/CUST-001 | \
  grep -i "INJECTED_TEST_VALUE"
```
Expected: no output (key value not in response)

**Invariants touched:** INV-05 (auth on all non-health endpoints), INV-06 (key never in response)
**Regression classification:** HARNESS-CANDIDATE (INV-05, INV-06)

---

### Session 2 Integration Check

```bash
docker compose up -d && sleep 5
# Health unauthenticated
curl -s http://localhost:8000/health
# Customer without key — must be 401
curl -s http://localhost:8000/customers/CUST-001
# Customer with wrong key — must be 401
curl -s -H "X-API-Key: wrong" http://localhost:8000/customers/CUST-001
```
Expected: health returns `{"status":"ok"}`. Both customer requests return `{"detail":"Invalid API key"}`. No 500s.

---

## Session 3 — Customer Lookup Endpoint

**Goal:** Complete customer lookup with parameterised queries, correct response shape,
404 handling, and database error handling.
**Branch:** session/s03_lookup
**Verification state at close:** Authenticated requests return correct customer data.
Unauthenticated requests return 401. Unknown IDs return 404. DB errors return 500 with no detail.

---

### Task 3.1 — Implement the customer lookup route

**CC Prompt:**
```
Replace the placeholder in GET /customers/{customer_id} in api/main.py with
the real customer lookup implementation.

Requirements:
1. The route must call get_db_connection() to open a connection.
2. Execute a SELECT query using a psycopg2 parameterised query:
   - Query: SELECT customer_id, risk_tier, risk_factors FROM customer_risk_profiles
     WHERE customer_id = %s
   - Pass customer_id as the second argument to cursor.execute() — never via
     string concatenation, f-string, or .format()
3. If fetchone() returns None: raise HTTPException(status_code=404,
   detail="Customer not found")
4. If the database call raises any exception: catch it and raise
   HTTPException(status_code=500, detail="Internal server error")
   — no exception detail may appear in the response
5. On success: return a JSON response with exactly these three fields:
   {"customer_id": row[0], "risk_tier": row[1], "risk_factors": row[2]}
   — no additional fields
6. Close the connection in a finally block regardless of outcome.
7. Define a Pydantic response model CustomerResponse with exactly three fields:
   customer_id: str, risk_tier: str, risk_factors: List[str]
   Use response_model=CustomerResponse on the route decorator.
   Set model_config = ConfigDict(extra='forbid') on the model.

TASK-SCOPED INVARIANT — INV-10:
The customer_id parameter must be passed exclusively as a psycopg2 parameterised
query argument. The SQL string must be a static literal. No string construction
of any kind is permitted. An implementation that builds the SQL string dynamically
is a structural violation regardless of whether it produces correct output.

TASK-SCOPED INVARIANT — INV-02:
The route must handle exactly three database outcomes:
- Row found → 200 with CustomerResponse body
- Row not found (fetchone() returns None) → 404 {"detail": "Customer not found"}
- Any database exception → 500 {"detail": "Internal server error"}
No other response code is permitted from this route.
```

**Test Cases:**
- TC-1: GET /customers/CUST-001 with correct key returns 200 with customer_id, risk_tier, risk_factors
- TC-2: Response values match database row exactly — verified by direct DB query
- TC-3: GET /customers/CUST-999 (non-existent) returns 404 {"detail": "Customer not found"}
- TC-4: DB stopped — GET /customers/CUST-001 returns 500 {"detail": "Internal server error"}
- TC-5: SQL injection string as customer_id returns 404 (not 200, not 500 with DB error)
- TC-6: Response body contains exactly three fields — no additional fields
- TC-7: risk_factors is a non-empty array of strings matching DB order

**Verification Command:**
```bash
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-001
```
Expected: `{"customer_id":"CUST-001","risk_tier":"<tier>","risk_factors":["<factor1>","<factor2>"]}`

**Supplementary verification — response matches DB:**
```bash
docker compose exec db psql -U riskuser -d riskdb \
  -c "SELECT customer_id, risk_tier, risk_factors FROM customer_risk_profiles WHERE customer_id='CUST-001';"
```
Compare output field-by-field against API response.

**Supplementary verification — 404:**
```bash
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-999
```
Expected: `{"detail":"Customer not found"}`

**Supplementary verification — 500 with no detail:**
```bash
docker compose stop db && sleep 2
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-001
docker compose start db && sleep 5
```
Expected: `{"detail":"Internal server error"}` — no psycopg2 detail

**Supplementary verification — SQL injection:**
```bash
curl -s -H "X-API-Key: $API_KEY" \
  "http://localhost:8000/customers/CUST-001'%20OR%20'1'%3D'1"
```
Expected: 404 `{"detail":"Customer not found"}`

**Supplementary verification — exact field set:**
```bash
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-001 | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print(sorted(d.keys()))"
```
Expected: `['customer_id', 'risk_factors', 'risk_tier']`

**Invariants touched:** INV-01, INV-02 (TASK-SCOPED), INV-04a, INV-07, INV-10 (TASK-SCOPED)
**Regression classification:** HARNESS-CANDIDATE (INV-01, INV-07), REGRESSION-RELEVANT (404, 500 paths)

---

### Session 3 Integration Check

```bash
docker compose up -d && sleep 5
# All three tiers
for id in CUST-001 CUST-004 CUST-007; do
  echo "--- $id ---"
  curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/$id
done
# 404
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-999
# 401
curl -s http://localhost:8000/customers/CUST-001
```

---

## Session 4 — Browser UI

**Goal:** HTML/JS UI served from GET / that allows operations staff to look up a customer
by ID and see the result or an appropriate error message.
**Branch:** session/s04_ui
**Verification state at close:** Browser UI renders correct API data verbatim. Error states display correctly.

---

### Task 4.1 — Write the browser UI

**CC Prompt:**
```
Write static/index.html.

Requirements:
1. Plain HTML, no frontend framework, no external CSS or JS libraries.
2. Contains:
   - A text input for customer ID (id="customer-id-input")
   - A submit button (id="submit-btn") labelled "Look Up"
   - A result display area (id="result-area") initially empty
3. On submit, JavaScript must:
   - Read the value from the customer ID input
   - Send a GET request to /customers/{customer_id} with the X-API-Key header
   - The API key must be read from a <meta name="api-key"> tag in the HTML head
     whose content attribute is populated from a template variable — use the
     literal placeholder {{API_KEY}} for now; Task 4.2 will wire the real value
4. On 200 response: display in result-area:
   - customer_id: render the customer_id field value directly as received
   - risk_tier: render the risk_tier field value directly as received
   - risk_factors: render each element of the risk_factors array directly as received
   - No label mapping, no capitalisation change, no sort, no filter on any field
5. On 404 response: display "Customer not found" in result-area
6. On 401 response: display "Unauthorized" in result-area
7. On any other error: display "An error occurred" in result-area
8. No transformation of any API response value before rendering.

TASK-SCOPED INVARIANT — INV-09:
The values of customer_id, risk_tier, and each element of risk_factors must be
rendered by setting element.textContent directly from the parsed JSON response
field. No switch statements, label maps, .toLowerCase(), .toUpperCase(), .replace(),
sort(), or filter() calls are permitted on these values before rendering.
A violation is any code path that produces DOM text that differs from the raw
API response value for these three fields.
```

**Test Cases:**
- TC-1: Submit CUST-001 with correct key — result-area displays customer_id, risk_tier, risk_factors verbatim
- TC-2: risk_tier displayed is exact string from API (e.g. "HIGH" not "High")
- TC-3: risk_factors elements displayed match API array order exactly
- TC-4: Submit CUST-999 — result-area displays "Customer not found"
- TC-5: Submit with no/wrong key — result-area displays "Unauthorized"
- TC-6: No JS transformation of any response value before rendering

**Verification Command:**
```bash
curl -s http://localhost:8000/
```
Expected: HTML response containing the input, button, and result-area elements.

**Supplementary verification — UI elements present:**
```bash
curl -s http://localhost:8000/ | grep -E "customer-id-input|submit-btn|result-area"
```
Expected: three matches.

**Supplementary verification — no transformation in JS (code review):**
```bash
grep -E "(switch|\.toLowerCase|\.toUpperCase|\.replace|\.sort|\.filter)" \
  customer-risk-api/static/index.html
```
Expected: no output.

**Invariants touched:** INV-09 (TASK-SCOPED — UI fidelity), INV-05 (X-API-Key header in JS fetch)
**Regression classification:** REGRESSION-RELEVANT

---

### Task 4.2 — Wire API key into UI from environment

**CC Prompt:**
```
Modify api/main.py GET / route to inject the API_KEY environment variable
into the HTML response.

Requirements:
1. Read the contents of static/index.html.
2. Replace the literal string {{API_KEY}} with the value of the API_KEY
   environment variable read via os.environ.get("API_KEY", "").
3. Return the modified HTML as an HTMLResponse.
4. The API_KEY value must be injected into the <meta name="api-key" content="...">
   tag only — it must not appear anywhere else in the rendered HTML.
5. Do not modify static/index.html itself — the replacement happens at serve time.
6. Do not log the API_KEY value.

TASK-SCOPED INVARIANT — INV-06:
The API_KEY value injected into the HTML is a governed surface. The meta tag
is the only permitted location. Confirm the replacement produces exactly one
occurrence of the key value in the rendered HTML — in the meta tag content only.
```

**Test Cases:**
- TC-1: GET / returns HTML containing the meta tag with API_KEY value in content attribute
- TC-2: API_KEY value appears exactly once in the rendered HTML
- TC-3: API_KEY value does not appear in any element outside the meta tag

**Verification Command:**
```bash
curl -s http://localhost:8000/ | grep 'meta name="api-key"'
```
Expected: one line containing the meta tag with a non-empty content attribute.

**Supplementary verification — key appears exactly once:**
```bash
curl -s http://localhost:8000/ | grep -c "$API_KEY"
```
Expected: `1`

**Invariants touched:** INV-06 (API key in HTML is a governed surface)
**Regression classification:** REGRESSION-RELEVANT

---

### Session 4 Integration Check

Open browser at http://localhost:8000.
- Submit CUST-001: confirm customer_id, risk_tier, risk_factors all display as received from API
- Submit CUST-999: confirm "Customer not found" displays
- Manually inspect: confirm no JS transformation of displayed values

---

## Session 5 — Hardening, Injection Tests, Full Invariant Run

**Goal:** SQL injection test suite, global exception handler, full invariant verification
script, README. Final acceptance gate.
**Branch:** session/s05_hardening
**Verification state at close:** All invariants pass. Clean cold start.

---

### Task 5.1 — Add global exception handler

**CC Prompt:**
```
Add a global exception handler to api/main.py.

Requirements:
1. Register an exception handler using @app.exception_handler(Exception) that:
   - Catches all unhandled exceptions not already handled by FastAPI
   - Returns JSONResponse(status_code=500, content={"detail": "Internal server error"})
   - Does not include any exception detail, message, type, or traceback in the response
   - Does not log the exception detail to stdout or stderr
2. Import JSONResponse from fastapi.responses.
3. Do not modify any existing route handler.
4. Do not add any other exception handlers.

TASK-SCOPED INVARIANT — INV-07:
The handler must be the backstop for all exceptions not caught by route handlers.
The response body must be the exact static literal {"detail": "Internal server error"}.
No exception attribute (.args, .message, str(e)) may appear in the response.
```

**Test Cases:**
- TC-1: An unhandled exception in a route returns 500 {"detail": "Internal server error"}
- TC-2: The 500 response body contains no exception class name, message, or traceback
- TC-3: Exception handler does not interfere with normal 200, 404, 401 responses

**Verification Command:**
```bash
# Trigger a 500 by stopping the DB and making an authenticated request
docker compose stop db && sleep 2
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-001
docker compose start db && sleep 5
```
Expected: `{"detail":"Internal server error"}` — no additional content.

**Supplementary verification — no internal detail:**
```bash
docker compose stop db && sleep 2
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-001 | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print(list(d.keys()))"
docker compose start db && sleep 5
```
Expected: `['detail']` — only one key in the response.

**Invariants touched:** INV-07
**Regression classification:** HARNESS-CANDIDATE (INV-07)

---

### Task 5.2 — Write SQL injection test suite

**CC Prompt:**
```
Write a Python test file at api/test_injection.py.

Requirements:
1. Use the requests library (add requests==2.31.0 to requirements.txt).
2. Test the following customer_id values as path parameters with a valid API key:
   - "' OR '1'='1"
   - "'; DROP TABLE customer_risk_profiles; --"
   - "CUST-001' AND '1'='1"
   - "1 UNION SELECT customer_id, risk_tier, risk_factors FROM customer_risk_profiles"
   - "CUST-001; SELECT * FROM customer_risk_profiles"
3. For each: assert the response status code is 404.
4. For each: assert the response body is {"detail": "Customer not found"}.
5. For each: assert the response body does not contain any table name, column name,
   or SQL keyword from the injected string.
6. The test file must be self-contained — no pytest, no fixtures.
   Run as: python api/test_injection.py
7. Print PASS or FAIL for each case. Exit 0 if all pass, exit 1 if any fail.

BASE_URL and API_KEY must be read from environment variables.
```

**Test Cases:**
- TC-1: All 5 injection strings return 404
- TC-2: No injection string causes a 200 response
- TC-3: No injection string causes a 500 with database error detail
- TC-4: Script exits 0 when all cases pass

**Verification Command:**
```bash
cd customer-risk-api && python api/test_injection.py
```
Expected: 5 PASS lines, exit code 0.

**Invariants touched:** INV-10 (SQL injection), INV-07 (no DB error detail in 500)
**Regression classification:** HARNESS-CANDIDATE (INV-10)

---

### Task 5.3 — Write the full invariant verification script

**CC Prompt:**
```
Write a shell script at verification/test_invariants.sh that verifies all
automated invariants for the Customer Risk API.

The script must:
1. Run against a live docker compose stack (assumed already running).
2. Test each of the following and print PASS or FAIL with invariant ID:

   INV-01: GET /customers/CUST-001 response values match DB row exactly
     - Query DB for CUST-001, compare customer_id, risk_tier, risk_factors to API response
   INV-02a: Known customer returns 200
   INV-02b: Unknown customer returns 404 {"detail": "Customer not found"}
   INV-02c: DB unreachable returns 500 {"detail": "Internal server error"}
     (stop db container, test, restart db container)
   INV-03: grep for UPDATE/DELETE/TRUNCATE/CREATE TRIGGER in init.sql — must find none
   INV-04a: 200 response has exactly three fields
   INV-04b: INSERT with invalid risk_tier is rejected by CHECK constraint
   INV-05a: Missing X-API-Key returns 401 {"detail": "Invalid API key"}
   INV-05b: Empty X-API-Key returns 401 {"detail": "Invalid API key"}
   INV-05c: Wrong X-API-Key returns 401 {"detail": "Invalid API key"}
   INV-06: 401 response body does not contain submitted key value
   INV-07: DB unreachable — 500 response contains only {"detail": "Internal server error"}
   INV-10: SQL injection string returns 404 (one representative case)
   INV-11: Tested via docker compose config — depends_on service_healthy present

   INV-08 (MANUAL): print reminder — verify by code review, no outbound imports
   INV-09 (MANUAL): print reminder — verify by UI browser test and JS code review

3. Print summary: N passed, N failed.
4. Exit 0 if all automated checks pass, exit 1 if any fail.
5. BASE_URL, API_KEY, POSTGRES_USER, POSTGRES_DB read from environment.
```

**Test Cases:**
- TC-1: Script runs to completion without crashing
- TC-2: All automated invariant checks report PASS on a correctly built system
- TC-3: Script exits 0 on full pass

**Verification Command:**
```bash
cd customer-risk-api && bash verification/test_invariants.sh
```
Expected: all automated checks PASS, exit 0, manual reminders printed for INV-08 and INV-09.

**Invariants touched:** All — this task is the full invariant verification gate.
**Regression classification:** HARNESS-CANDIDATE (all invariants)

---

### Task 5.4 — Write README.md

**CC Prompt:**
```
Write README.md at the repo root (customer-risk-api/README.md).

Requirements:
1. Sections: Overview, Prerequisites, Setup, Running the Stack, API Reference,
   Running Tests, Known Limitations.
2. Setup section must document:
   - cp .env.example .env
   - Required .env values and their purpose
   - docker compose up
3. API Reference must document:
   - GET /health (unauthenticated)
   - GET /customers/{customer_id} (X-API-Key required)
   - GET / (UI)
   - Response shapes for 200, 401, 404, 500
4. Known Limitations must state:
   - Single shared API key — no per-user revocation
   - Database reset requires docker compose down -v
5. Do not include any internal system detail, credentials, or architecture decisions.
```

**Test Cases:**
- TC-1: README.md exists and is readable
- TC-2: Contains all five required sections
- TC-3: Known Limitations section present with both documented limitations

**Verification Command:**
```bash
grep -E "^## (Overview|Prerequisites|Setup|Running|API Reference|Known Limitations)" \
  customer-risk-api/README.md | wc -l
```
Expected: `6` or more section headers matching the pattern.

**Invariants touched:** None.
**Regression classification:** NOT-REGRESSION-RELEVANT

---

### Session 5 Integration Check — Final Gate

Cold start from clean state:

```bash
docker compose down -v
docker compose up -d
sleep 10
# Full invariant script
bash verification/test_invariants.sh
# Injection suite
python api/test_injection.py
```

Expected: all automated invariant checks PASS, injection suite exits 0.
This is the Phase 8 readiness gate.

---

## Invariant Coverage Map

| Invariant | Scope | First enforced | Verified by |
|---|---|---|---|
| INV-01 | GLOBAL | Task 3.1 | Task 3.1 TC-2, Task 5.3 INV-01 check |
| INV-02 | TASK-SCOPED | Task 3.1 | Task 3.1 TC-3/TC-4, Task 5.3 INV-02a/b/c |
| INV-03 | GLOBAL | Task 1.2 | Task 1.2 TC-5, Task 5.3 INV-03 check |
| INV-04a | GLOBAL | Task 3.1 | Task 3.1 TC-6, Task 5.3 INV-04a check |
| INV-04b | TASK-SCOPED | Task 1.2 | Task 1.2 TC-2, Task 5.3 INV-04b check |
| INV-05 | GLOBAL | Task 2.4 | Task 2.4 TC-1/2/3/5, Task 5.3 INV-05a/b/c |
| INV-06 | GLOBAL | Task 2.4 | Task 2.4 TC-6 + log check, Task 4.2, Task 5.3 INV-06 |
| INV-07 | GLOBAL | Task 2.3 | Task 2.3 TC-2, Task 5.1, Task 5.3 INV-07 |
| INV-08 | GLOBAL | Task 1.3 | MANUAL — Task 5.3 reminder |
| INV-09 | TASK-SCOPED | Task 4.1 | Task 4.1 TC-6 + code review, Task 5.3 reminder |
| INV-10 | TASK-SCOPED | Task 3.1 | Task 3.1 TC-5, Task 5.2, Task 5.3 INV-10 check |
| INV-11 | TASK-SCOPED | Task 1.3 | Task 1.3 TC-3, Task 5.3 INV-11 check |

---

## Regression Classification Summary

| Classification | Tasks |
|---|---|
| HARNESS-CANDIDATE | 1.2 (INV-03), 2.4 (INV-05/06), 3.1 (INV-01/07), 5.1 (INV-07), 5.2 (INV-10), 5.3 (all) |
| REGRESSION-RELEVANT | 1.3, 2.2, 2.3, 3.1 (404/500 paths), 4.1, 4.2 |
| NOT-REGRESSION-RELEVANT | 1.1, 2.1, 5.4 |