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
| v1.6 | 2026-06-19 | Engineer | Session 4 opened. Branch session/s04_ui. |
| v1.7 | 2026-06-19 | CC | Session 4 integration check — PASS. Session closed. |
| v1.8 | 2026-06-20 | Engineer | Session 5 opened. Branch session/s05_hardening. |
| v1.9 | 2026-06-20 | CC | Session 5 integration check — PASS. Session closed. |

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
**Date:** 2026-06-19
**Status:** COMPLETE — integration check PASS 2026-06-19

**Goal:** Serve `index.html` from `GET /` in FastAPI. Build a plain HTML + vanilla JS form that accepts a customer ID and API key, calls `/customers/{id}`, and displays the result. No frontend framework.
**Verification state at close (target):** Browser loads the UI, submits a valid ID, and displays correct tier and risk factors.

---

### Task 4.1 — Write index.html browser UI

**Status:** COMPLETE

**Files modified:**
- `customer-risk-api/static/index.html`

**Invariants touched:** INV-09 (textContent set directly from parsed JSON; no switch, toLowerCase, toUpperCase, replace, sort, filter on response values), IC-3 (X-API-Key sent via JS header, not URL), IC-4 (API key read from meta tag placeholder `{{API_KEY}}`; not rendered or logged).

**Decision log:**
- API key sourced from `<meta name="api-key" content="{{API_KEY}}">` — placeholder wired in Task 4.2.
- `encodeURIComponent` used on customer ID input to prevent path injection.
- All three response fields rendered with `element.textContent = data.<field>` — no transformation.

---

### Task 4.2 — Wire API key into index.html via GET / route

**Status:** COMPLETE

**Files modified:**
- `customer-risk-api/api/main.py`

**Invariants touched:** IC-4 / INV-06 (API_KEY injected into meta tag content only; `.replace(..., 1)` limits substitution to exactly one occurrence; key never logged).

**Decision log:**
- `str.replace("{{API_KEY}}", ..., 1)` — count=1 ensures at most one substitution, guaranteeing the key cannot appear in the rendered HTML beyond the single meta tag.
- `os.environ.get("API_KEY", "")` — empty fallback prevents a KeyError; the UI will fail auth requests gracefully if the env var is unset.
- Replacement is at serve-time only; `static/index.html` on disk is never modified.

---

### Session 4 Integration Check

**Status:** PASS — 2026-06-19

**Commands:**
```bash
# TC-1: meta tag present with injected key
curl -s http://localhost:8000/ | grep 'meta name="api-key"'
# TC-2: key appears exactly once in rendered HTML
curl -s http://localhost:8000/ | grep -c "$API_KEY"
# TC-3: all three UI elements present
curl -s http://localhost:8000/ | grep -oE "customer-id-input|submit-btn|result-area"
# TC-4: no JS transformation
grep -E "(switch|\.toLowerCase|\.toUpperCase|\.replace|\.sort|\.filter)" customer-risk-api/static/index.html
# Customer lookups
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-001
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-007
curl -s -H "X-API-Key: $API_KEY" http://localhost:8000/customers/CUST-999
curl -s http://localhost:8000/customers/CUST-001
```

**Result:** PASS

**Actual output:**
```
<meta name="api-key" content="api-key-2026">                           TC-1 PASS
1                                                                       TC-2 PASS
customer-id-input / result-area / submit-btn                            TC-3 PASS
PASS — no matches                                                       TC-4 PASS
{"customer_id":"CUST-001","risk_tier":"LOW","risk_factors":["low credit utilisation","stable employment history"]}   HTTP 200
{"customer_id":"CUST-007","risk_tier":"HIGH","risk_factors":["default on prior loan","high credit utilisation","county court judgement"]}  HTTP 200
{"detail":"Customer not found"}  HTTP 404
{"detail":"Invalid API key"}  HTTP 401
GET /  HTTP 200
```

**Structural fix applied:** `docker-compose.yml` amended to add `./static:/app/static` volume mount. The static directory was outside the `./api` Docker build context and unreachable inside the container. This is a one-line non-destructive addition; no invariants affected.

---

### Session 4 Completion

**Date closed:** 2026-06-19
**Final status:** COMPLETE — all tasks delivered, integration check PASS.

**Invariants exercised this session:**

| Invariant | Outcome |
|---|---|
| INV-09 | PASS — all response values rendered via textContent; no transformation code in index.html |
| IC-4 / INV-06 | PASS — API_KEY injected into meta tag content only; count=1 replacement; appears exactly once |
| IC-3 / INV-05 | PASS — GET / is unauthenticated; X-API-Key sent as header in JS fetch |
| IC-5 / INV-07 | PASS — error states display static strings; no internal detail surfaced in UI |

**Handoff to Session 5:**
- `index.html` and `GET /` are complete. No changes expected.
- Session 5 scope: `api/main.py`, `api/test_injection.py`, `api/requirements.txt`, `verification/test_invariants.sh`, `README.md`.

---

## Session 5 — Hardening, Injection Tests, Full Invariant Run

**Branch:** session/s05_hardening
**Date:** 2026-06-20
**Status:** COMPLETE — integration check PASS 2026-06-20

**Goal:** Global exception handler, SQL injection test suite, full invariant verification script, README. Final acceptance gate.
**Verification state at close:** All automated invariants PASS on a cold start. Injection suite exits 0.

---

### Task 5.1 — Add global exception handler

**Status:** COMPLETE

**Files modified:**
- `customer-risk-api/api/main.py`

**Invariants touched:** IC-5 / INV-07 — `@app.exception_handler(Exception)` returns the exact static literal `{"detail": "Internal server error"}`; no exception attribute appears in response; no logging of exception detail.

**Decision log:**
- Handler signature takes `(request, exc)` but ignores both — response is fully static.
- `JSONResponse` added to `fastapi.responses` import; no other import changes.
- Existing route handlers (`get_customer` catches its own exceptions) remain unchanged.

---

### Task 5.2 — Write SQL injection test suite

**Status:** COMPLETE

**Files created/modified:**
- `customer-risk-api/api/test_injection.py`
- `customer-risk-api/api/requirements.txt` — added `requests==2.31.0`

**Invariants touched:** INV-10 — all 5 injection strings return 404; none causes 200 or 500 with DB detail.

**Decision log:**
- `requests.utils.quote(payload, safe='')` percent-encodes the injection string for the URL path — preserves the full payload as a single path segment.
- Body check compares `resp.json() == {"detail": "Customer not found"}` exactly.
- Leak check: `payload.lower() not in resp.text.lower()` — catches any reflection of the raw SQL payload in the response body.

---

### Task 5.3 — Write full invariant verification script

**Status:** COMPLETE

**Files created:**
- `customer-risk-api/verification/test_invariants.sh`

**Invariants touched:** All automated invariants (INV-01 through INV-11 except INV-08/09 which are MANUAL).

**Decision log:**
- Python detected via `command -v python3 || python` — works on both Linux/Mac and Windows Git Bash.
- INV-01 comparison uses `export` to pass DB row and API response into a Python heredoc — avoids shell quoting issues with JSON strings.
- INV-02c and INV-07 share the same DB-down request — one `docker compose stop/start` cycle covers both.
- DB restart uses a `pg_isready` poll loop (up to 20 seconds) rather than a fixed sleep.
- INV-04b failure is expected (psycopg2 / psql returns non-zero on CHECK violation) — `|| true` prevents script exit.
- INV-08 and INV-09 printed as MANUAL reminders; do not affect pass/fail count.

---

### Task 5.4 — Write README.md

**Status:** COMPLETE

**Files created:**
- `customer-risk-api/README.md`

**Invariants touched:** None.

**Decision log:**
- Sections: Overview, Prerequisites, Setup, Running the Stack, API Reference, Running Tests, Known Limitations.
- API Reference documents all four status codes (200, 401, 404, 500) including the static literal body for each error.
- Testing section distinguishes the injection suite (`python api/test_injection.py`) from the invariant shell script (`bash verification/test_invariants.sh`) to match the two separate gate commands.

---

### Session 5 Integration Check — Final Gate

**Status:** PASS — 2026-06-20

**Commands (cold start from clean state):**
```bash
docker compose down -v
docker compose up -d
sleep 10
bash verification/test_invariants.sh
python api/test_injection.py
```

**Expected:** All automated invariant checks PASS. Injection suite exits 0. This is the Phase 8 readiness gate.

**Result:** PASS — invariant script 11/11 PASS (INV-01, INV-02a, INV-02b, INV-02c, INV-03, INV-04a, INV-04b, INV-05a, INV-05b, INV-05c, INV-06, INV-07, INV-10, INV-11); injection suite 5/5 PASS, exit 0.

---

### Session 5 Completion

**Date closed:** 2026-06-20
**Final status:** COMPLETE — all tasks delivered, integration check PASS.

**Files delivered on branch `session/s05_hardening`:**

| File | Task |
|---|---|
| `customer-risk-api/api/main.py` | 5.1 — global exception handler added |
| `customer-risk-api/api/test_injection.py` | 5.2 — injection test suite |
| `customer-risk-api/api/requirements.txt` | 5.2 — `requests==2.31.0` added |
| `customer-risk-api/verification/test_invariants.sh` | 5.3 — full invariant shell script |
| `customer-risk-api/README.md` | 5.4 — project README |

**Invariants exercised this session:**

| Invariant | Outcome |
|---|---|
| IC-5 / INV-07 | PASS — `@app.exception_handler(Exception)` returns static literal; no exception detail in response |
| INV-10 | PASS — 5/5 injection payloads return 404 with exact body; no payload reflected |
| INV-01 through INV-11 (automated) | PASS — full invariant script run on cold start |

**Phase 8 readiness gate:** PASS. Project frozen at Phase 5 / v1.0 of CLAUDE.md.
