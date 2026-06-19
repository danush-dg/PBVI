# SESSION_LOG.md — Customer Risk API

## Changelog
| Version | Date | Author | Change |
|---|---|---|---|
| v1.0 | 2026-06-19 | Engineer | Session 1 opened. |
| v1.1 | 2026-06-19 | Engineer | Session 1 integration check — PASS. Session closed. |

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

**Files to create:**
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
**Status:** NOT STARTED

---

## Session 3 — Customer Lookup Endpoint

**Branch:** session/s03_lookup
**Status:** NOT STARTED

---

## Session 4 — Browser UI

**Branch:** session/s04_ui
**Status:** NOT STARTED

---

## Session 5 — Hardening, Injection Tests, Full Invariant Run

**Branch:** session/s05_hardening
**Status:** NOT STARTED
