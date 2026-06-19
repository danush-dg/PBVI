# VERIFICATION_RECORD.md — Customer Risk API

## Changelog
| Version | Date | Author | Change |
|---|---|---|---|
| v1.0 | 2026-06-19 | Engineer | Session 1 opened. |

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
| TC-1 | All 7 files exist at correct paths | `find customer-risk-api -type f \| sort` | 7 paths listed (see below) | SKIP | |
| TC-2 | No extra files or directories | Same command | Exactly the 7 paths, nothing else | SKIP | |

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
| TC-1 | Table exists with correct columns after container start | `docker compose exec db psql -U riskuser -d riskdb -c "\d customer_risk_profiles"` | customer_id, risk_tier, risk_factors columns | SKIP | |
| TC-2 | CHECK constraint rejects invalid risk_tier | See supplementary | Output contains "violates check constraint" | SKIP | |
| TC-3 | Exactly 3 rows per tier | See primary verification | 3 HIGH, 3 LOW, 3 MEDIUM | SKIP | |
| TC-4 | No row has empty risk_factors | `docker compose exec db psql -U riskuser -d riskdb -c "SELECT COUNT(*) FROM customer_risk_profiles WHERE risk_factors = '{}';"` | `0` | SKIP | |
| TC-5 | No write DDL in init.sql | `grep -iE "(UPDATE\|DELETE\|TRUNCATE\|CREATE TRIGGER\|CREATE FUNCTION)" customer-risk-api/db/init.sql` | No output (exit code 1) | SKIP | |

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
**Result:** SKIP

**Supplementary — CHECK constraint:**
```bash
docker compose exec db psql -U riskuser -d riskdb \
  -c "INSERT INTO customer_risk_profiles VALUES ('TEST-999', 'CRITICAL', '{\"factor\"}');" 2>&1 | grep -i "violates"
```
**Expected:** output contains "violates check constraint"
**Result:** SKIP

**Supplementary — no write DDL:**
```bash
grep -iE "(UPDATE|DELETE|TRUNCATE|CREATE TRIGGER|CREATE FUNCTION)" customer-risk-api/db/init.sql
```
**Expected:** no output (grep exit code 1 = PASS)
**Result:** SKIP

---

### Task 1.3 — docker-compose.yml and .env.example

| TC | Description | Command | Expected | Result | Notes |
|---|---|---|---|---|---|
| TC-1 | `docker compose config` exits 0 | `cd customer-risk-api && docker compose config --quiet && echo "CONFIG VALID"` | `CONFIG VALID` | SKIP | |
| TC-2 | db service has HEALTHCHECK | `grep -A5 "healthcheck" customer-risk-api/docker-compose.yml` | pg_isready present | SKIP | |
| TC-3 | api depends_on db with service_healthy | `grep -A3 "depends_on" customer-risk-api/docker-compose.yml` | condition: service_healthy | SKIP | |
| TC-4 | No external network definitions | `grep -i "external: true" customer-risk-api/docker-compose.yml` | No output | SKIP | |
| TC-5 | All six keys in .env.example | `grep -c "=" customer-risk-api/.env.example` | `6` | SKIP | |

**Primary verification command:**
```bash
cd customer-risk-api && docker compose config --quiet && echo "CONFIG VALID"
```
**Expected:** `CONFIG VALID` with no errors.
**Result:** SKIP

**Supplementary — no external networks:**
```bash
grep -i "external: true" customer-risk-api/docker-compose.yml
```
**Expected:** no output
**Result:** SKIP

**Supplementary — six env keys:**
```bash
grep -c "=" customer-risk-api/.env.example
```
**Expected:** `6`
**Result:** SKIP

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

**Result:** SKIP

**Actual output:** —

---

## Session 2 — FastAPI Application Core

All verification records: NOT STARTED

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
| INV-03 | Task 1.2 | Yes (Task 1.2 TC-5, Task 5.3) | SKIP |
| INV-04a | Task 3.1 | Yes (Task 5.3) | NOT REACHED |
| INV-04b | Task 1.2 | Yes (Task 1.2 TC-2, Task 5.3) | SKIP |
| INV-05 | Task 2.4 | Yes (Task 5.3) | NOT REACHED |
| INV-06 | Task 2.4 | Yes (Task 5.3) | NOT REACHED |
| INV-07 | Task 2.3 | Yes (Task 5.3) | NOT REACHED |
| INV-08 | Task 1.3 | MANUAL | SKIP |
| INV-09 | Task 4.1 | MANUAL | NOT REACHED |
| INV-10 | Task 3.1 | Yes (Task 5.2, Task 5.3) | NOT REACHED |
| INV-11 | Task 1.3 | Yes (Task 1.3 TC-3, Task 5.3) | SKIP |
