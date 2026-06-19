# SESSION_LOG.md — Customer Risk API

## Changelog
| Version | Date | Author | Change |
|---|---|---|---|
| v1.0 | 2026-06-19 | Engineer | Session 1 opened. |
| v1.1 | 2026-06-19 | Engineer | Session 1 integration check — PASS. Session closed. |
| v1.2 | 2026-06-19 | Engineer | Session 2 opened. Branch session/s02_api_core. |
| v1.3 | 2026-06-19 | CC | Session 2 integration check — PASS. Session closed. |
| v1.4 | 2026-06-19 | Engineer | Session 3 opened. Branch session/s03_lookup_endpoint. |
| v1.5 | 2026-06-19 | CC | Session 3 integration check — PASS. Session closed. |

---

## Session 1 — Project Scaffold and Database

**Branch:** session/s01_scaffold
**Date:** 2026-06-19
**Status:** COMPLETE — integration check PASS 2026-06-19

**Goal:** Postgres running with correct schema and seed data. No application code.
**Verification state at close:** Direct psql query returns 9+ seed rows across all three tiers.

---

### Task 1.1 — Create the project directory structure

**Status:** COMPLETE

**Files created:**
- `customer-risk-api/docker-compose.yml` — empty placeholder
- `customer-risk-api/.env.example` — empty placeholder
- `customer-risk-api/db/init.sql` — empty placeholder
- `customer-risk-api/api/Dockerfile` — empty placeholder
- `customer-risk-api/api/requirements.txt` — empty placeholder
- `customer-risk-api/api/main.py` — empty placeholder
- `customer-risk-api/static/index.html` — empty placeholder

**Invariants touched:** None — structural scaffolding only.

**Decision log:** None.

---

### Task 1.2 — Write the database schema and seed data

**Status:** COMPLETE — all TCs PASS (TC-5 static, TC-1/2/3/4 live DB via integration check)

**Files modified:**
- `customer-risk-api/db/init.sql`

**Invariants touched:** INV-03 (no write triggers in schema), INV-04b (CHECK constraint).

**Decision log:** None.

---

### Task 1.3 — Write docker-compose.yml and .env.example

**Status:** COMPLETE

**Files modified:**
- `customer-risk-api/docker-compose.yml`
- `customer-risk-api/.env.example`

**Invariants touched:** INV-08 (no external network definitions), INV-11 (healthcheck + depends_on).

**Decision log:** None.

---

### Session 1 Integration Check

**Status:** PASS — 2026-06-19

**Command:**
```bash
cd customer-risk-api
docker compose up db -d
docker compose exec db psql -U postgres -d risk_db \
  -c "SELECT customer_id, risk_tier FROM customer_risk_profiles ORDER BY customer_id;"
```

**Expected:** 9 rows returned, all three tiers present, no errors.

**Result:** PASS — 9 rows returned (3 LOW, 3 MEDIUM, 3 HIGH), no errors.

---

## Session 2 — FastAPI Application Core

**Branch:** session/s02_api_core
**Date:** 2026-06-19
**Status:** COMPLETE — integration check PASS 2026-06-19

**Goal:** FastAPI container with database connection and API key authentication. No customer lookup logic yet — skeleton, connection function, and auth dependency only.
**Verification state at close:** API container starts, /health returns 200, unauthenticated requests to /customers/{id} return 401.

---

### Task 2.1 — Write requirements.txt and Dockerfile

**Status:** COMPLETE — commit `3a35db3`

**Files written:**
- `customer-risk-api/api/requirements.txt`
- `customer-risk-api/api/Dockerfile`

**Invariants touched:** None directly.

**Decision log:** None.

---

### Task 2.2 — Write the FastAPI application skeleton

**Status:** COMPLETE — commit `ade2918`

**Files modified:**
- `customer-risk-api/api/main.py`

**Invariants touched:** INV-05 (health check is sole unauthenticated surface).

**Decision log:** None.

---

### Task 2.3 — Write the database connection function

**Status:** COMPLETE — commit `ade2918`

**Files modified:**
- `customer-risk-api/api/main.py`

**Invariants touched:** INV-07 (psycopg2 exceptions must not propagate out of this function).

**Decision log:** None.

---

### Task 2.4 — Write the API key authentication dependency

**Status:** COMPLETE — commit `ade2918`

**Files modified:**
- `customer-risk-api/api/main.py`

**Invariants touched:** INV-05 (auth on all non-health endpoints), INV-06 (key never in response).

**Decision log:** None.

---

### Session 2 Integration Check

**Status:** PASS — 2026-06-19

**Commands:**
```bash
docker compose up -d && sleep 5
curl -s http://localhost:8000/health
curl -s http://localhost:8000/customers/CUST-001
curl -s -H "X-API-Key: wrong" http://localhost:8000/customers/CUST-001
```

**Expected:** health returns `{"status":"ok"}`. Both customer requests return `{"detail":"Invalid API key"}`. No 500s.

**Result:** PASS — `{"status":"ok"}` on health; `{"detail":"Invalid API key"}` (HTTP 401) on both customer requests. No 500s.

---

### Session 2 Completion

**Date closed:** 2026-06-19
**Final status:** COMPLETE — all tasks delivered, integration check PASS.

**Commits on branch `session/s02_api_core`:**

| Commit | Task | Description |
|---|---|---|
| `3a35db3` | 2.1 | `[S2] task-2.1: add Dockerfile and pinned requirements` |
| `ade2918` | 2.2 / 2.3 / 2.4 | `[S2] task-2.2/2.3/2.4: FastAPI skeleton, DB connection, auth dependency` |

**Invariants exercised this session:**

| Invariant | Outcome |
|---|---|
| IC-3 / INV-05 | PASS — /health unauthenticated; /customers/{id} rejects absent, empty, wrong key with 401 |
| IC-4 / INV-06 | PASS — 401 body is static literal; key value absent from all response bodies |
| IC-5 / INV-07 | PASS — psycopg2.Error wrapped as RuntimeError; no internal detail in responses |

**Handoff to Session 3:**
- `main.py` placeholder `{"message":"placeholder"}` in `get_customer` must be replaced with real DB lookup.
- `get_db_connection()` is ready; `verify_api_key` is wired. No changes to auth or connection layer expected.
- Session 3 scope: `customer-risk-api/api/main.py` only.

---

## Session 3 — Customer Lookup Endpoint

**Branch:** session/s03_lookup_endpoint
**Date:** 2026-06-19
**Status:** COMPLETE — integration check PASS 2026-06-19

**Goal:** Replace placeholder in `get_customer` with real parameterised DB query. Add 404 and 500 handling. Add Pydantic response model. No changes to auth or connection layer.
**Verification state at close:** Authenticated requests return correct customer data verbatim. Unknown IDs return 404. DB errors return 500 with no internal detail.

---

### Task 3.1 — Implement the customer lookup route

**Status:** COMPLETE — commit `1428b0e`

**Files to modify:**
- `customer-risk-api/api/main.py`

**Invariants touched:** INV-01 (data fidelity), INV-02 (three outcomes only), INV-04a (exactly three response fields), INV-07 (no DB detail in 500), INV-10 (parameterised query only).

**Decision log:** None.

---

### Session 3 Integration Check

**Status:** PASS — 2026-06-19

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

**Result:** PASS — all 5 requests matched expected output exactly.

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

### Session 3 Completion

**Date closed:** 2026-06-19
**Final status:** COMPLETE — all tasks delivered, integration check PASS.

**Commits on branch `session/s03_lookup_endpoint`:**

| Commit | Task | Description |
|---|---|---|
| `1428b0e` | 3.1 | `[S3] task-3.1: implement customer lookup route` |

**Invariants exercised this session:**

| Invariant | Outcome |
|---|---|
| IC-1 / INV-01 | PASS — response values match DB row exactly, no transformation |
| IC-2 / INV-02 | PASS — exactly three outcomes: 200, 404, 500 |
| INV-04a | PASS — response body has exactly three fields |
| IC-5 / INV-07 | PASS — all exceptions caught; static literal in 500 response |
| INV-10 | PASS — parameterised `%s` binding; SQL string is a static constant |

**Handoff to Session 4:**
- `get_customer` is complete. No changes to this route expected.
- Session 4 scope: `customer-risk-api/static/index.html` and `customer-risk-api/api/main.py` (GET / route only).

---

## Session 4 — Browser UI

**Branch:** session/s04_ui
**Status:** NOT STARTED

---

## Session 5 — Hardening, Injection Tests, Full Invariant Run

**Branch:** session/s05_hardening
**Status:** NOT STARTED
