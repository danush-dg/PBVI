---
version: v1.0
METHODOLOGY_VERSION: PBVI-v5.0
source: PBVI Phase 5 greenfield
frozen: true
---

# Claude.md — Customer Risk API
## Version: v1.0 · FROZEN · 2026-06-19

## Changelog
| Version | Date | Author | Change |
|---|---|---|---|
| v1.0 | 2026-06-19 | Engineer | Greenfield — Initial. Frozen at Phase 5. |

---

## Section 1 — System Intent

The Customer Risk API is a read-only authenticated lookup service that returns
pre-assessed customer risk tier and risk factors from a Postgres database. It does
not calculate risk, write to the database, or make external network calls. Success
means operations staff can retrieve accurate, unmodified risk data through a browser
or HTTP client using a single API key, with the full stack starting from
`docker compose up` and no other setup.

---

## Section 2 — Hard Invariants

Each function, method, or handler must have a single stateable purpose.
Conditional nesting exceeding two levels is a structural violation — refactor
before proceeding. This is never negotiable.

IC-1 (INV-01): The value of `risk_tier` and every element of `risk_factors` in
the API response must exactly match the database row for that `customer_id`,
including element order in the `risk_factors` array. No transformation,
capitalisation change, reordering, or substitution between database read and JSON
response is permitted. This is never negotiable.

IC-2 (INV-03): The application must never issue any SQL statement that modifies
the database at runtime. Only SELECT statements are permitted. The database schema
must define no triggers that fire write operations as a side effect of SELECT
queries. This is never negotiable.

IC-3 (INV-05): Every request to any endpoint except GET /health must be rejected
with HTTP 401 and body `{"detail": "Invalid API key"}` if the X-API-Key header is
absent, empty, or does not exactly match the API_KEY environment variable. No
customer data may be returned to any caller that fails this check. GET /health is
the sole unauthenticated surface and must return only `{"status": "ok"}`. This is
never negotiable.

IC-4 (INV-06): The value of the API_KEY environment variable must never appear in
any HTTP response body, HTTP response header, application log output, or Docker
container log output. The 401 detail must be the static literal
`"Invalid API key"` — no f-string, format(), or interpolation of any kind. This is
never negotiable.

IC-5 (INV-07): No information about the system's internal implementation,
dependencies, or infrastructure may appear in any HTTP response body under any
circumstances. All exceptions from the database layer must be caught by a FastAPI
exception handler registered at the application level and replaced with HTTP 500
`{"detail": "Internal server error"}` before reaching the caller. This is never
negotiable.

---

## Section 3 — Scope Boundary

**Permitted files — create or modify only these:**

Session 1:
- `customer-risk-api/docker-compose.yml`
- `customer-risk-api/.env.example`
- `customer-risk-api/db/init.sql`

Session 2:
- `customer-risk-api/api/Dockerfile`
- `customer-risk-api/api/requirements.txt`
- `customer-risk-api/api/main.py`

Session 3:
- `customer-risk-api/api/main.py`

Session 4:
- `customer-risk-api/static/index.html`
- `customer-risk-api/api/main.py`

Session 5:
- `customer-risk-api/api/main.py`
- `customer-risk-api/api/test_injection.py`
- `customer-risk-api/api/requirements.txt`
- `customer-risk-api/verification/test_invariants.sh`
- `customer-risk-api/README.md`

**Explicitly out of scope — never create or modify:**
- `docs/Claude.md` — this file; never modified by CC under any circumstances
- Any file not listed above
- Any migration tool, ORM, connection pool, or external HTTP client
- Any write endpoint, admin route, or user management feature
- Any TLS configuration, rate limiting, or production hardening

---

## Section 4 — Fixed Stack

| Component | Technology | Version |
|---|---|---|
| Orchestration | Docker Compose | current |
| Database | PostgreSQL | 15 |
| Backend | FastAPI | 0.110.0 |
| Server | uvicorn | 0.29.0 |
| DB driver | psycopg2-binary | 2.9.9 |
| Frontend | Plain HTML + Vanilla JavaScript | — |
| Python | Python | 3.11 |

**Hard constraints on stack:**
- No ORM — psycopg2 direct SQL only
- No connection pool — new connection per request, closed in finally block
- No external HTTP client — no requests, httpx, urllib calls to external hosts
- No frontend framework — plain HTML and vanilla JS only
- All SQL queries must use psycopg2 parameterised syntax (`%s` placeholder,
  arguments as second argument to `cursor.execute()`) — no f-strings, no
  string concatenation, no `.format()` in any SQL statement
- API_KEY and all database credentials sourced from environment variables only —
  never hardcoded

---

## Section 5 — Rules

**Rule 1:** All file references use full paths from repo root — never bare filenames.

**Rule 2:** All files inside any enhancement package carry their ENH-NNN prefix —
no exceptions.

**Rule 3:** Any file not in the mandatory set for its directory and not registered
in PROJECT_MANIFEST.md must not be read by CC as authoritative input. CC flags
unregistered files and reports them to the engineer before proceeding.