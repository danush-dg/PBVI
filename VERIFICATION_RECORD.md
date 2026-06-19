# VERIFICATION_RECORD.md — Customer Risk API

## Changelog
| Version | Date | Author | Change |
|---|---|---|---|
| v1.0 | 2026-06-19 | Engineer | Session 1 opened. |
| v1.1 | 2026-06-19 | Engineer | Session 1 integration check — all TCs closed PASS. |

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
| INV-03 | Task 1.2 | Yes (Task 1.2 TC-5, Task 5.3) | PASS |
| INV-04a | Task 3.1 | Yes (Task 5.3) | NOT REACHED |
| INV-04b | Task 1.2 | Yes (Task 1.2 TC-2, Task 5.3) | PASS |
| INV-05 | Task 2.4 | Yes (Task 5.3) | NOT REACHED |
| INV-06 | Task 2.4 | Yes (Task 5.3) | NOT REACHED |
| INV-07 | Task 2.3 | Yes (Task 5.3) | NOT REACHED |
| INV-08 | Task 1.3 | MANUAL | MANUAL — no external imports; verified by code review |
| INV-09 | Task 4.1 | MANUAL | NOT REACHED |
| INV-10 | Task 3.1 | Yes (Task 5.2, Task 5.3) | NOT REACHED |
| INV-11 | Task 1.3 | Yes (Task 1.3 TC-3, Task 5.3) | PASS |
