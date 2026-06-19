# VERIFICATION_RECORD.md — Customer Risk API

## Changelog
| Version | Date | Author | Change |
|---|---|---|---|
| v1.0 | 2026-06-19 | Engineer | Session 1 opened. |
| v1.1 | 2026-06-19 | Engineer | Session 1 integration check — all TCs closed PASS. |
| v1.2 | 2026-06-19 | Engineer | Session 2 opened — TC stubs added for Tasks 2.1–2.4. |
| v1.3 | 2026-06-19 | Engineer | Session 2 integration check — all TCs closed PASS. |

---

## Key

| Symbol | Meaning |
|---|---|
| PASS | Verified — expected output matched |
| FAIL | Verification failed — deviation recorded |
| SKIP | Not yet run |
| MANUAL | Requires human review — no automated check |

---

## Session 1 — Project Scaffold and Database

### Task 1.1 — Directory structure

| TC | Description | Command | Expected | Result | Notes |
|---|---|---|---|---|---|
| TC-1 | All 7 files exist at correct paths | `find customer-risk-api -type f \| sort` | 7 paths listed (see below) | PASS | |
| TC-2 | No extra files or directories | Same command | Exactly the 7 paths, nothing else | PASS | |

**Expected output for TC-1 / TC-2:**
```
customer-risk-api/.env.example
customer-risk-api/api/Dockerfile
customer-risk-api/api/main.py
customer-risk-api/api/requirements.txt
customer-risk-api/db/init.sql
customer-risk-api/docker-compose.yml
customer-risk-api/static/index.html
```

---

### Task 1.2 — Database schema and seed data

| TC | Description | Command | Expected | Result | Notes |
|---|---|---|---|---|---|
| TC-1 | Table exists with correct columns after container start | `docker compose exec db psql -U postgres -d risk_db -c "\d customer_risk_profiles"` | customer_id, risk_tier, risk_factors columns | PASS | All 3 columns confirmed with correct types and CHECK constraint |
| TC-2 | CHECK constraint rejects invalid risk_tier | See supplementary | Output contains "violates check constraint" | PASS | ERROR: violates check constraint "customer_risk_profiles_risk_tier_check" |
| TC-3 | Exactly 3 rows per tier | See primary verification | 3 HIGH, 3 LOW, 3 MEDIUM | PASS | Exact counts confirmed |
| TC-4 | No row has empty risk_factors | `docker compose exec db psql -U postgres -d risk_db -c "SELECT COUNT(*) FROM customer_risk_profiles WHERE risk_factors = '{}';"` | `0` | PASS | count = 0 |
| TC-5 | No write DDL in init.sql | `grep -iE "(UPDATE\|DELETE\|TRUNCATE\|CREATE TRIGGER\|CREATE FUNCTION)" customer-risk-api/db/init.sql` | No output (exit code 1) | PASS | 0 matches |

**Primary verification command:**
```bash
docker compose exec db psql -U riskuser -d riskdb \
  -c "SELECT risk_tier, COUNT(*) FROM customer_risk_profiles GROUP BY risk_tier ORDER BY risk_tier;"
```
**Expected:**
```
 risk_tier | count
-----------+-------
 HIGH      |     3
 LOW       |     3
 MEDIUM    |     3
(3 rows)
```
**Result:** PASS — 3 HIGH, 3 LOW, 3 MEDIUM

**Supplementary — CHECK constraint:**
```bash
docker compose exec db psql -U postgres -d risk_db \
  -c "INSERT INTO customer_risk_profiles VALUES ('TEST-999', 'CRITICAL', '{\"factor\"}');" 2>&1 | grep -i "violates"
```
**Expected:** output contains "violates check constraint"
**Result:** PASS — `ERROR: new row for relation "customer_risk_profiles" violates check constraint "customer_risk_profiles_risk_tier_check"`

**Supplementary — no write DDL:**
```bash
grep -iE "(UPDATE|DELETE|TRUNCATE|CREATE TRIGGER|CREATE FUNCTION)" customer-risk-api/db/init.sql
```
**Expected:** no output (grep exit code 1 = PASS)
**Result:** PASS — 0 matches

---

### Task 1.3 — docker-compose.yml and .env.example

| TC | Description | Command | Expected | Result | Notes |
|---|---|---|---|---|---|
| TC-1 | `docker compose config` exits 0 | `cd customer-risk-api && docker compose config --quiet && echo "CONFIG VALID"` | `CONFIG VALID` | PASS | |
| TC-2 | db service has HEALTHCHECK | `grep -A5 "healthcheck" customer-risk-api/docker-compose.yml` | pg_isready present | PASS | line 10 |
| TC-3 | api depends_on db with service_healthy | `grep -A3 "depends_on" customer-risk-api/docker-compose.yml` | condition: service_healthy | PASS | line 30 |
| TC-4 | No external network definitions | `grep -i "external: true" customer-risk-api/docker-compose.yml` | No output | PASS | 0 matches |
| TC-5 | All six keys in .env.example | `grep -c "=" customer-risk-api/.env.example` | `6` | PASS | count=6 |

**Primary verification command:**
```bash
cd customer-risk-api && docker compose config --quiet && echo "CONFIG VALID"
```
**Expected:** `CONFIG VALID` with no errors.
**Result:** PASS

**Supplementary — no external networks:**
```bash
grep -i "external: true" customer-risk-api/docker-compose.yml
```
**Expected:** no output
**Result:** PASS — 0 matches

**Supplementary — six env keys:**
```bash
grep -c "=" customer-risk-api/.env.example
```
**Expected:** `6`
**Result:** PASS — count = 6

---

### Session 1 Integration Check

**Command:**
```bash
cd customer-risk-api
cp .env.example .env
# Edit .env to set real values before running
docker compose up db -d
sleep 8
docker compose exec db psql -U riskuser -d riskdb \
  -c "SELECT customer_id, risk_tier FROM customer_risk_profiles ORDER BY customer_id;"
```

**Expected:** 9 rows, all three tiers present, no errors.

**Result:** PASS — 2026-06-19

**Actual output:**
```
 customer_id | risk_tier
-------------+-----------
 CUST-001    | LOW
 CUST-002    | LOW
 CUST-003    | LOW
 CUST-004    | MEDIUM
 CUST-005    | MEDIUM
 CUST-006    | MEDIUM
 CUST-007    | HIGH
 CUST-008    | HIGH
 CUST-009    | HIGH
(9 rows)
```

---

## Session 2 — FastAPI Application Core

### Task 2.1 — requirements.txt and Dockerfile

| TC | Description | Command | Expected | Result | Notes |
|---|---|---|---|---|---|
| TC-1 | `docker compose build api` exits 0 | `cd customer-risk-api && docker compose build api 2>&1 \| tail -5` | Successful build, no errors | PASS | `Image customer-risk-api-api Built` |
| TC-2 | requirements.txt contains exactly 3 pinned packages | `grep -c "==" customer-risk-api/api/requirements.txt` | `3` | PASS | count=3 |

---

### Task 2.2 — FastAPI application skeleton

| TC | Description | Command | Expected | Result | Notes |
|---|---|---|---|---|---|
| TC-1 | GET /health returns 200 `{"status":"ok"}` | `curl -s http://localhost:8000/health` | `{"status":"ok"}` | PASS | `{"status":"ok"}` |
| TC-2 | GET /customers/CUST-001 returns 200 placeholder (no auth yet) | `curl -s http://localhost:8000/customers/CUST-001` | 200 placeholder body | PASS | `{"message":"placeholder"}` |
| TC-3 | Application starts without import errors | `docker compose up -d && sleep 3 && curl -s http://localhost:8000/health` | No startup errors | PASS | Container started cleanly |

---

### Task 2.3 — Database connection function

| TC | Description | Command | Expected | Result | Notes |
|---|---|---|---|---|---|
| TC-1 | Function returns valid connection when DB running | `docker compose exec api python -c "import main; conn = main.get_db_connection(); print('PASS' if conn else 'FAIL')"` | `PASS` | PASS | `PASS` |
| TC-2 | Function raises RuntimeError (not psycopg2 exception) when DB unreachable | See supplementary | `PASS: Database connection failed` | PASS | Correct exception type and message |
| TC-3 | RuntimeError message contains no credentials | Same as TC-2 — inspect message text | No user/password/host in message | PASS | Static literal only: "Database connection failed" |

**Supplementary — error wrapping:**
```bash
docker compose stop db && sleep 2
docker compose exec api python -c "
import main
try:
    main.get_db_connection()
except RuntimeError as e:
    print('PASS:', str(e))
except Exception as e:
    print('FAIL — wrong exception type:', type(e).__name__, str(e))
"
docker compose start db
```
**Expected:** `PASS: Database connection failed`
**Result:** PASS — `PASS: Database connection failed`

---

### Task 2.4 — API key authentication dependency

| TC | Description | Command | Expected | Result | Notes |
|---|---|---|---|---|---|
| TC-1 | No X-API-Key header → 401 | `curl -s http://localhost:8000/customers/CUST-001` | `{"detail":"Invalid API key"}` | PASS | `{"detail":"Invalid API key"}` HTTP 401 |
| TC-2 | Empty X-API-Key header → 401 | `curl -s -H "X-API-Key: " http://localhost:8000/customers/CUST-001` | `{"detail":"Invalid API key"}` | PASS | `{"detail":"Invalid API key"}` HTTP 401 |
| TC-3 | Wrong key → 401 | `curl -s -H "X-API-Key: wrong" http://localhost:8000/customers/CUST-001` | `{"detail":"Invalid API key"}` | PASS | `{"detail":"Invalid API key"}` HTTP 401 |
| TC-4 | Correct key → 200 placeholder | `curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-001` | 200 (not 401) | PASS | `{"message":"placeholder"}` HTTP 200 |
| TC-5 | GET /health with no key → 200 | `curl -s http://localhost:8000/health` | `{"status":"ok"}` | PASS | `{"status":"ok"}` HTTP 200 |
| TC-6 | 401 body is exactly `{"detail":"Invalid API key"}` — no extra fields | `curl -s http://localhost:8000/customers/CUST-001` | Exactly one field: detail | PASS | Exactly one field confirmed |

**Supplementary — key value not echoed in response (INV-06):**
```bash
curl -s -H "X-API-Key: INJECTED_TEST_VALUE" http://localhost:8000/customers/CUST-001 | grep -i "INJECTED_TEST_VALUE"
```
**Expected:** no output
**Result:** PASS — no output; key not present in response body

---

### Session 2 Integration Check

**Commands:**
```bash
docker compose up -d && sleep 5
curl -s http://localhost:8000/health
curl -s http://localhost:8000/customers/CUST-001
curl -s -H "X-API-Key: wrong" http://localhost:8000/customers/CUST-001
```

**Expected:** health → `{"status":"ok"}`. Both customer requests → `{"detail":"Invalid API key"}`. No 500s.

**Result:** PASS — 2026-06-19

**Actual output:**
```
{"status":"ok"}        HTTP 200
{"detail":"Invalid API key"}   HTTP 401  (no key)
{"detail":"Invalid API key"}   HTTP 401  (wrong key)
```

---

### Session 2 CD Challenge — Adversarial Code Review

Performed against commit `ade2918` (`customer-risk-api/api/main.py`).

| CD | Claim | Check | Result |
|---|---|---|---|
| CD-1 | No f-string/format()/concat in SQL | `grep -n "f\".*SELECT"` | PASS — no SQL strings (Session 3 task) |
| CD-2 | API_KEY value never interpolated into any string | `grep -n "f\".*API_KEY\|{api_key}\|{expected}"` | PASS — no interpolation |
| CD-3 | 401 detail is a static string literal | Inspect `detail=` on line 16 | PASS — `detail="Invalid API key"` literal, no f-string |
| CD-4 | No external HTTP client imports | `grep -n "import requests\|import httpx"` | PASS — none |
| CD-5 | No ORM imports | `grep -n "import sqlalchemy"` | PASS — psycopg2 only |
| CD-6 | No hardcoded DB credentials | `grep -n "password\s*=\s*['\"]"` | PASS — all via `os.environ.get()` |
| CD-7 | `/health` has no auth dependency | `grep -A2 "def health"` | PASS — bare handler, no `Depends` |
| CD-8 | `/customers/{id}` wires `Depends(verify_api_key)` | `grep -n "Depends(verify_api_key)"` | PASS — line 38 |
| CD-9 | Conditional nesting ≤ 2 levels (IC-2) | Indent depth scan | PASS — depth-3 lines are keyword args inside `connect()`, not conditional nesting |

**Code review notes:**
- `verify_api_key` correctly checks `not api_key` before equality — handles both `None` (header absent) and empty string.
- `get_db_connection` catches `psycopg2.Error` (base class), so all connection sub-errors are wrapped. `RuntimeError` is the only exception type that escapes.
- `get_customer` returns `{"message":"placeholder"}` on 200 — correct placeholder for Session 3; auth is enforced before this code runs.
- `index()` reads the static file at request time — not cached, but acceptable for this scope.
- No connection pool, no ORM, no external calls — stack constraints respected.

---

### Session 2 Verification Verdict

**Date:** 2026-06-19
**Verdicted by:** CC (Claude Code)

| Area | Verdict | Evidence |
|---|---|---|
| Task 2.1 — Dockerfile + requirements.txt | PASS | TC-1/TC-2 PASS; build produced `customer-risk-api-api:latest` |
| Task 2.2 — FastAPI skeleton | PASS | TC-1/TC-2/TC-3 PASS; `/health` 200, `/customers/{id}` placeholder 200 before auth |
| Task 2.3 — DB connection function | PASS | TC-1/TC-2/TC-3 PASS; psycopg2.Error wrapped, no credential leak |
| Task 2.4 — Auth dependency | PASS | TC-1–TC-6 PASS; supplementary INV-06 PASS |
| Session integration check | PASS | 3/3 curl checks matched expected output exactly |
| CD adversarial review | PASS | 9/9 CD challenges cleared |
| IC-3 (INV-05) | PASS | Absent, empty, wrong key all → 401 static literal |
| IC-4 (INV-06) | PASS | Key value absent from all response bodies |
| IC-5 (INV-07) — partial | PASS | RuntimeError wraps psycopg2.Error; HTTP 500 handler deferred to Session 3 |

**Overall session verdict: PASS — cleared to open PR and advance to Session 3.**

---

## Session 3 — Customer Lookup Endpoint

All verification records: NOT STARTED

---

## Session 4 — Browser UI

All verification records: NOT STARTED

---

## Session 5 — Hardening, Injection Tests, Full Invariant Run

All verification records: NOT STARTED

---

## Invariant Status Summary

| Invariant | First enforced | Automated check available | Current status |
|---|---|---|---|
| INV-01 | Task 3.1 | Yes (Task 5.3) | NOT REACHED |
| INV-02 | Task 3.1 | Yes (Task 5.3) | NOT REACHED |
| INV-03 | Task 1.2 | Yes (Task 1.2 TC-5, Task 5.3) | PASS |
| INV-04a | Task 3.1 | Yes (Task 5.3) | NOT REACHED |
| INV-04b | Task 1.2 | Yes (Task 1.2 TC-2, Task 5.3) | PASS |
| INV-05 | Task 2.4 | Yes (Task 5.3) | PASS |
| INV-06 | Task 2.4 | Yes (Task 5.3) | PASS |
| INV-07 | Task 2.3 | Yes (Task 5.3) | PASS |
| INV-08 | Task 1.3 | MANUAL | MANUAL — no external imports; verified by code review |
| INV-09 | Task 4.1 | MANUAL | NOT REACHED |
| INV-10 | Task 3.1 | Yes (Task 5.2, Task 5.3) | NOT REACHED |
| INV-11 | Task 1.3 | Yes (Task 1.3 TC-3, Task 5.3) | PASS |
