# VERIFICATION_RECORD.md — Customer Risk API

## Changelog
| Version | Date | Author | Change |
|---|---|---|---|
| v1.0 | 2026-06-19 | Engineer | Session 1 opened. |
| v1.1 | 2026-06-19 | Engineer | Session 1 integration check — all TCs closed PASS. |
| v1.2 | 2026-06-19 | Engineer | Session 2 opened — TC stubs added for Tasks 2.1–2.4. |
| v1.3 | 2026-06-19 | Engineer | Session 2 integration check — all TCs closed PASS. |
| v1.4 | 2026-06-19 | Engineer | Session 3 opened — TC stubs added for Task 3.1. |
| v1.5 | 2026-06-19 | CC | Session 3 integration check — all TCs closed PASS. |
| v1.6 | 2026-06-19 | Engineer | Session 4 opened — TC stubs added for Tasks 4.1–4.2. |
| v1.7 | 2026-06-19 | CC | Session 4 integration check — all TCs closed PASS. |
| v1.8 | 2026-06-20 | Engineer | Session 5 opened — TC stubs added for Tasks 5.1–5.4. |
| v1.9 | 2026-06-20 | CC | Session 5 integration check — all TCs closed PASS. |

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
{"status":"ok"}               HTTP 200
{"detail":"Invalid API key"}  HTTP 401  (no key)
{"detail":"Invalid API key"}  HTTP 401  (wrong key)
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
- `verify_api_key` checks `not api_key` before equality — handles both `None` (header absent) and empty string.
- `get_db_connection` catches `psycopg2.Error` (base class); `RuntimeError` is the only exception type that escapes.
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

### Task 3.1 — Customer lookup route

| TC | Description | Command | Expected | Result | Notes |
|---|---|---|---|---|---|
| TC-1 | Correct key → 200 with customer_id, risk_tier, risk_factors | `curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-001` | `{"customer_id":"CUST-001","risk_tier":"...","risk_factors":[...]}` | PASS | `{"customer_id":"CUST-001","risk_tier":"LOW","risk_factors":["low credit utilisation","stable employment history"]}` |
| TC-2 | Response values match DB row exactly | DB query vs API response field-by-field | All three fields identical | PASS | customer_id, risk_tier, risk_factors identical |
| TC-3 | Non-existent ID → 404 | `curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-999` | `{"detail":"Customer not found"}` | PASS | `{"detail":"Customer not found"}` HTTP 404 |
| TC-4 | DB stopped → 500 no detail | Stop db, curl, start db | `{"detail":"Internal server error"}` | PASS | `{"detail":"Internal server error"}` HTTP 500 |
| TC-5 | SQL injection string → 404 | `curl -s -H "X-API-Key: $API_KEY" "http://localhost:8000/customers/CUST-001'%20OR%20'1'%3D'1"` | 404 `{"detail":"Customer not found"}` | PASS | `{"detail":"Customer not found"}` HTTP 404 |
| TC-6 | Response body has exactly three fields | Parse keys from 200 response | `['customer_id', 'risk_factors', 'risk_tier']` | PASS | `['customer_id', 'risk_factors', 'risk_tier']` |
| TC-7 | risk_factors is non-empty array matching DB order | Compare DB array to response array | Identical element order | PASS | 2-element and 3-element arrays confirmed in order |

**Predictions:**
- TC-1/2 (data fidelity): Parameterised SELECT returns row as-is; no transformation in response path → response will match DB exactly.
- TC-3 (404): `fetchone()` returns `None` for unknown ID → `HTTPException(404)` raised.
- TC-4 (500): `get_db_connection()` raises `RuntimeError`; route catches it → `HTTPException(500)` with static literal.
- TC-5 (injection): Parameterised `%s` binding treats entire string as a literal value → no row matches → 404.
- TC-6 (field set): `response_model=CustomerResponse` with `extra='forbid'` enforces exactly three fields.

**Supplementary — response matches DB:**
```bash
docker compose exec db psql -U postgres -d risk_db -t \
  -c "SELECT customer_id, risk_tier, risk_factors FROM customer_risk_profiles WHERE customer_id='CUST-001';"
```
**Expected:** Fields match API response verbatim.
**Result:** PASS — ` CUST-001 | LOW | {"low credit utilisation","stable employment history"}` — identical to API.

**Supplementary — exact field set:**
```bash
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-001 | \
  python -c "import sys,json; d=json.load(sys.stdin); print(sorted(d.keys()))"
```
**Expected:** `['customer_id', 'risk_factors', 'risk_tier']`
**Result:** PASS — `['customer_id', 'risk_factors', 'risk_tier']`

**Supplementary — 500 no internal detail:**
```bash
docker compose stop db && sleep 2
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-001
docker compose start db && sleep 5
```
**Expected:** `{"detail":"Internal server error"}` — one key only.
**Result:** PASS — `{"detail":"Internal server error"}` HTTP 500

---

### Session 3 Integration Check

**Commands:**
```bash
docker compose up -d && sleep 5
for id in CUST-001 CUST-004 CUST-007; do
  echo "--- $id ---"
  curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/$id
done
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-999
curl -s http://localhost:8000/customers/CUST-001
```

**Expected:** One 200 per tier with correct data. CUST-999 → 404 `{"detail":"Customer not found"}`. No-key request → 401 `{"detail":"Invalid API key"}`. No 500s.

**Result:** PASS — 2026-06-19

**Actual output:**
```
--- CUST-001 ---
{"customer_id":"CUST-001","risk_tier":"LOW","risk_factors":["low credit utilisation","stable employment history"]}  HTTP 200
--- CUST-004 ---
{"customer_id":"CUST-004","risk_tier":"MEDIUM","risk_factors":["recent address change","moderate debt-to-income ratio"]}  HTTP 200
--- CUST-007 ---
{"customer_id":"CUST-007","risk_tier":"HIGH","risk_factors":["default on prior loan","high credit utilisation","county court judgement"]}  HTTP 200
{"detail":"Customer not found"}  HTTP 404
{"detail":"Invalid API key"}  HTTP 401
```

---

### Session 3 Verification Verdict

**Date:** 2026-06-19
**Verdicted by:** CC (Claude Code)

| Area | Verdict | Evidence |
|---|---|---|
| Task 3.1 — Customer lookup route | PASS | TC-1–TC-7 PASS; all supplementary checks PASS |
| Session integration check | PASS | 5/5 requests matched expected output exactly |
| IC-1 / INV-01 | PASS | API values identical to DB row, no transformation |
| IC-2 / INV-02 | PASS | Exactly 3 outcomes: 200 / 404 / 500 |
| INV-04a | PASS | Response has exactly 3 fields enforced by Pydantic `extra='forbid'` |
| IC-5 / INV-07 | PASS | All exceptions caught; static literal in 500 |
| INV-10 | PASS | SQL is a static constant; `%s` parameterised binding; injection → 404 |

**Overall session verdict: PASS — cleared to open PR and advance to Session 4.**

---

## Session 4 — Browser UI

### Task 4.1 — index.html browser UI

| TC | Description | Command | Expected | Result | Notes |
|---|---|---|---|---|---|
| TC-1 | GET / returns 200 | `curl -so /dev/null -w "%{http_code}" http://localhost:8000/` | `200` | PASS | `200` |
| TC-2 | GET / requires no API key | `curl -s http://localhost:8000/` | 200 (not 401) | PASS | 200 — no auth required |
| TC-3 | All three UI element IDs present | `curl -s http://localhost:8000/ \| grep -oE "customer-id-input\|submit-btn\|result-area"` | three matches | PASS | all three found |
| TC-4 | No JS transformation of response values | `grep -E "(switch\|\.toLowerCase\|\.toUpperCase\|\.replace\|\.sort\|\.filter)" index.html` | no output | PASS | 0 matches |

---

### Task 4.2 — Wire API key into GET / route

| TC | Description | Command | Expected | Result | Notes |
|---|---|---|---|---|---|
| TC-1 | Meta tag contains injected API_KEY | `curl -s http://localhost:8000/ \| grep 'meta name="api-key"'` | line with non-empty content | PASS | `content="api-key-2026"` |
| TC-2 | API_KEY appears exactly once in rendered HTML | `curl -s http://localhost:8000/ \| grep -c "$API_KEY"` | `1` | PASS | count = 1 |
| TC-3 | Customer lookup via UI key works end-to-end | `curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-001` | 200 with customer data | PASS | correct JSON returned |

---

### Session 4 Integration Check

| Check | Expected | Result |
|---|---|---|
| CUST-001 → 200 verbatim data | `{"customer_id":"CUST-001","risk_tier":"LOW",...}` | PASS |
| CUST-007 → 200 HIGH tier verbatim | `{"customer_id":"CUST-007","risk_tier":"HIGH",...}` | PASS |
| CUST-999 → 404 | `{"detail":"Customer not found"}` | PASS |
| No key → 401 | `{"detail":"Invalid API key"}` | PASS |
| GET / → 200 HTML | HTTP 200 | PASS |
| API_KEY count in HTML = 1 | `1` | PASS |
| No JS transformation code | 0 grep matches | PASS |

---

## Session 5 — Hardening, Injection Tests, Full Invariant Run

### Task 5.1 — Global exception handler

| TC | Description | Command | Expected | Result | Notes |
|---|---|---|---|---|---|
| TC-1 | Handler registered at app level | `grep -n "exception_handler(Exception)" customer-risk-api/api/main.py` | line present | PASS | line 13 |
| TC-2 | Response is exactly `{"detail":"Internal server error"}` | `docker compose stop db && curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-001` | `{"detail":"Internal server error"}` HTTP 500 | PASS | `{"detail":"Internal server error"}` HTTP 500 |
| TC-3 | No exception attribute in response body | Parse TC-2 body keys | exactly one key: `detail` | PASS | one field confirmed |
| TC-4 | Handler body contains no f-string or interpolation | `grep -n 'f".*Internal\|format.*Internal' customer-risk-api/api/main.py` | no output | PASS | 0 matches — static literal only |

---

### Task 5.2 — SQL injection test suite

| TC | Description | Command | Expected | Result | Notes |
|---|---|---|---|---|---|
| TC-1 | Injection suite file exists | `ls customer-risk-api/api/test_injection.py` | file present | PASS | file present |
| TC-2 | `requests` added to requirements.txt | `grep "requests==" customer-risk-api/api/requirements.txt` | `requests==2.31.0` | PASS | `requests==2.31.0` |
| TC-3 | All 5 injection payloads return 404 | `python api/test_injection.py` | 5 passed, 0 failed; exit 0 | PASS | 5 passed, 0 failed |
| TC-4 | No injection payload reflected in response body | Per-case `no_leak` check inside suite | no payload text in response | PASS | all 5 cases clean |

**Injection payloads covered:**
```
' OR '1'='1
'; DROP TABLE customer_risk_profiles; --
CUST-001' AND '1'='1
1 UNION SELECT customer_id, risk_tier, risk_factors FROM customer_risk_profiles
CUST-001; SELECT * FROM customer_risk_profiles
```

---

### Task 5.3 — Full invariant verification script

| TC | Description | Expected | Result | Notes |
|---|---|---|---|---|
| TC-1 | Script file is executable | `bash verification/test_invariants.sh` exits without parse error | PASS | no parse errors |
| TC-2 | INV-01 check passes | PASS    INV-01 | PASS | API values match DB row |
| TC-3 | INV-02a/b/c checks pass | PASS    INV-02a / INV-02b / INV-02c | PASS | 200 / 404 / 500 outcomes |
| TC-4 | INV-03 check passes | PASS    INV-03 | PASS | no write DDL in init.sql |
| TC-5 | INV-04a/b checks pass | PASS    INV-04a / INV-04b | PASS | 3 fields / CHECK constraint |
| TC-6 | INV-05a/b/c checks pass | PASS    INV-05a / INV-05b / INV-05c | PASS | absent / empty / wrong key → 401 |
| TC-7 | INV-06 check passes | PASS    INV-06 | PASS | submitted key not reflected |
| TC-8 | INV-07 check passes | PASS    INV-07 | PASS | 500 body one field only |
| TC-9 | INV-10 check passes | PASS    INV-10 | PASS | injection → 404 |
| TC-10 | INV-11 check passes | PASS    INV-11 | PASS | service_healthy in compose |
| TC-11 | Script summary exits 0 | `=== Summary: N passed, 0 failed ===` | PASS | 0 failures |

---

### Task 5.4 — README.md

| TC | Description | Expected | Result | Notes |
|---|---|---|---|---|
| TC-1 | File exists | `ls customer-risk-api/README.md` | file present | PASS | file present |
| TC-2 | Setup section present | contains "cp .env.example .env" | PASS | present |
| TC-3 | API Reference covers all four status codes | 200 / 401 / 404 / 500 documented | PASS | all four present |
| TC-4 | Running Tests section distinguishes injection suite from invariant script | both commands documented separately | PASS | both commands present |

---

### Session 5 Integration Check — Final Gate

**Commands (cold start from clean state):**
```bash
docker compose down -v
docker compose up -d
sleep 10
bash verification/test_invariants.sh
python api/test_injection.py
```

**Expected:** All automated invariant checks PASS, injection suite exits 0.

**Result:** PASS — 2026-06-20

**Invariant script output:**
```
=== Customer Risk API — Invariant Verification ===

PASS    INV-01
PASS    INV-02a
PASS    INV-02b
PASS    INV-02c
PASS    INV-03
PASS    INV-04a
PASS    INV-04b
PASS    INV-05a
PASS    INV-05b
PASS    INV-05c
PASS    INV-06
PASS    INV-07
PASS    INV-10
PASS    INV-11

MANUAL  INV-08 — code review — confirm no requests/httpx/urllib external calls in api/main.py
MANUAL  INV-09 — browser test — confirm UI renders values verbatim; check index.html for JS transforms

=== Summary: 14 passed, 0 failed ===
```

**Injection suite output:**
```
PASS  "' OR '1'='1"
PASS  "'; DROP TABLE customer_risk_profiles; --"
PASS  "CUST-001' AND '1'='1"
PASS  "1 UNION SELECT customer_id, risk_tier, risk_factors FROM customer_risk_profiles"
PASS  "CUST-001; SELECT * FROM customer_risk_profiles"

5 passed, 0 failed
```

---

### Session 5 Verification Verdict

**Date:** 2026-06-20
**Verdicted by:** CC (Claude Code)

| Area | Verdict | Evidence |
|---|---|---|
| Task 5.1 — Global exception handler | PASS | TC-1–TC-4 PASS; 500 body is static literal; one field only |
| Task 5.2 — Injection test suite | PASS | TC-1–TC-4 PASS; 5/5 payloads → 404; no reflection |
| Task 5.3 — Invariant verification script | PASS | TC-1–TC-11 PASS; 14 automated checks; 0 failures |
| Task 5.4 — README.md | PASS | TC-1–TC-4 PASS; all sections present |
| Final Gate integration check | PASS | Invariant script 14/14; injection suite 5/5; exit 0 |
| IC-5 / INV-07 | PASS | `@app.exception_handler(Exception)` present; static literal only |
| INV-10 | PASS | 5 injection payloads → 404; parameterised query confirmed |

**Overall session verdict: PASS — Phase 8 readiness gate cleared. Project complete.**

---

## Invariant Status Summary

| Invariant | First enforced | Automated check available | Current status |
|---|---|---|---|
| INV-01 | Task 3.1 | Yes (Task 5.3) | PASS |
| INV-02 | Task 3.1 | Yes (Task 5.3) | PASS |
| INV-03 | Task 1.2 | Yes (Task 1.2 TC-5, Task 5.3) | PASS |
| INV-04a | Task 3.1 | Yes (Task 5.3) | PASS |
| INV-04b | Task 1.2 | Yes (Task 1.2 TC-2, Task 5.3) | PASS |
| INV-05 | Task 2.4 | Yes (Task 5.3) | PASS |
| INV-06 | Task 2.4 | Yes (Task 5.3) | PASS |
| INV-07 | Task 2.3 | Yes (Task 5.3) | PASS |
| INV-08 | Task 1.3 | MANUAL | MANUAL — no external imports; verified by code review |
| INV-09 | Task 4.1 | MANUAL | MANUAL — browser test; textContent rendering; no JS transform found in index.html |
| INV-10 | Task 3.1 | Yes (Task 5.2, Task 5.3) | PASS |
| INV-11 | Task 1.3 | Yes (Task 1.3 TC-3, Task 5.3) | PASS |
