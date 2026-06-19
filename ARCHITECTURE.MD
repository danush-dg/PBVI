# ARCHITECTURE.md — Customer Risk API

## Changelog
| Version | Date | Author | Change |
|---|---|---|---|
| v1.0 | 2026-06-19 | Engineer | Greenfield — Initial |

---

## 1. Problem Framing

### What this system solves

Operations staff need to look up a customer's risk tier and the factors that drove that
assessment. Currently this requires direct database access and ad-hoc SQL queries —
an approach that is slow, error-prone, and bypasses access controls. This system
provides a controlled, authenticated access layer over a pre-populated risk profile
database so that operations staff can retrieve risk information reliably, without
database credentials, and without writing code.

### What this system explicitly does not do

- It does not calculate or assess risk. All risk data is pre-assessed and stored.
  The system only retrieves and returns what the database holds.
- It does not manage users, roles, or per-user credentials.
- It does not write to the database. There are no create, update, or delete operations
  of any kind.
- It does not make external service calls. Everything runs locally within the
  Docker Compose stack.
- It does not provide production hardening — no TLS, no rate limiting, no enterprise
  secrets management.

---

## 2. Five Key Design Decisions

### Decision 1 — Single FastAPI container serves both the API and the UI

**What was decided:** One Docker Compose application service handles all three
concerns — API key authentication, customer lookup, and serving the static HTML/JS
UI file. The UI is returned from a dedicated `GET /` route in the same FastAPI
process. There is no separate nginx container, no separate frontend service.

**Rationale:** The requirements brief explicitly prohibits separate frontend hosting
and a separate deployment target. Serving the HTML file from the same FastAPI
container is the most direct way to satisfy that constraint. It avoids an nginx
configuration surface, eliminates a third Compose service, and keeps the entire
application stack to exactly two containers — the API and the database.

**Alternatives rejected:**

- *Separate nginx container serving static files, FastAPI behind it (Architecture C):*
  Adds an nginx configuration file as a new maintenance surface, introduces a
  three-service health dependency chain, and requires `proxy_pass` configuration with
  explicit header forwarding for `X-API-Key`. The structural benefit — network-boundary
  enforcement of the read-only constraint — is not justified at this scale and scope.

- *Separate nginx UI container, FastAPI API container (Architecture B):*
  Creates a direct conflict with the "no separate frontend hosting" constraint. Also
  introduces CORS configuration requirements and requires the API host and port to be
  hardcoded in the browser JavaScript. Rejected on constraint grounds.

---

### Decision 2 — New database connection per request via psycopg2, no connection pool

**What was decided:** Each inbound request to the customer lookup endpoint opens a
new psycopg2 connection, executes the SELECT query, and closes the connection.
No connection pool is used.

**Rationale:** This is a low-volume internal tool serving a small fixed set of
operations staff. The connection overhead is not a meaningful constraint at this
scale. A new connection per request is simpler to reason about — there is no pool
state, no connection lifecycle to manage, and no pool exhaustion failure mode.
The requirements brief also explicitly prohibits an ORM, and using psycopg2 directly
without a pool is consistent with that intent.

**Alternatives rejected:**

- *SQLAlchemy connection pool:* Rejected because the brief prohibits ORM use, and
  SQLAlchemy's pooling mechanism is bundled with its ORM layer. Adding it for pooling
  alone would introduce the abstraction the brief explicitly rules out.

- *psycopg2 connection pool (without SQLAlchemy):* psycopg2 has a built-in
  `ThreadedConnectionPool`. Rejected because the added complexity — pool
  initialisation, checkout/return discipline, pool exhaustion handling — is not
  justified for the access volume this system will serve.

---

### Decision 3 — API key authentication via a single shared `X-API-Key` header

**What was decided:** All endpoints are protected by a FastAPI dependency that reads
an `API_KEY` environment variable and compares it against the `X-API-Key` request
header. A single shared key is used across all operations staff. Requests without
the header, or with an incorrect value, receive HTTP 401.

**Rationale:** User management, RBAC, and per-user credentials are explicitly out of
scope in the requirements brief. A single shared API key is the minimum viable
authentication mechanism that satisfies the "no unauthenticated access" constraint
without introducing scope creep. The key is sourced from the environment at runtime —
it is never stored in the codebase.

**Alternatives rejected:**

- *Per-user API keys with a key registry:* Requires a user management layer that the
  brief explicitly excludes. Rejected on scope grounds.

- *HTTP Basic Auth:* Introduces a username/password model with no stated requirement
  for usernames in this system. Rejected as unnecessary complexity for a single
  shared secret.

- *JWT / session tokens:* Requires token issuance, validation, and expiry logic.
  No justification for this complexity given the stated scope.

---

### Decision 4 — Database initialised and seeded entirely from `db/init.sql` at container start

**What was decided:** A single `db/init.sql` file contains both the schema DDL
and the `INSERT` seed data. Postgres automatically executes scripts placed in
`/docker-entrypoint-initdb.d/` on first run. No separate migration tool, no
separate seed script, no additional startup step.

**Rationale:** The requirements brief mandates that the entire system starts with
`docker compose up` and no manual setup steps beyond supplying a `.env` file.
The Postgres init script mechanism satisfies this precisely — the database is
schema-ready and data-populated as a side effect of container startup. One file,
one mechanism, zero additional tooling.

**Alternatives rejected:**

- *Alembic migrations + separate seed script:* Alembic is appropriate for systems
  where the schema evolves over time. This system has a fixed, read-only schema with
  no planned migrations. Adding a migration runner would be complexity with no return.

- *Separate seed step after startup (e.g. `docker compose run api python seed.py`):*
  Violates the "no manual setup steps" constraint. Rejected on constraint grounds.

- *Fixtures loaded at application startup via FastAPI lifespan events:* Couples the
  seed data to the application process rather than the database layer. If the API
  container restarts without the database volume being reset, the seed logic runs
  against an already-populated database — requiring idempotency guards that the
  `init.sql` mechanism provides for free.

---

### Decision 5 — Raw SQL via psycopg2, no ORM

**What was decided:** Database access uses psycopg2 directly with parameterised
queries. No ORM or query builder is used anywhere in the codebase.

**Rationale:** The requirements brief explicitly prohibits ORM use. Beyond compliance,
the system has exactly one substantive query — a `SELECT` by `customer_id`. An ORM
adds a dependency and an abstraction layer with no benefit for a single read-only
query against a single table. Parameterised queries via psycopg2 provide SQL injection
protection without the overhead of a query builder.

**Alternatives rejected:**

- *SQLAlchemy Core (expression language, no ORM):* Even the non-ORM layer of
  SQLAlchemy adds dependency weight and a learning surface for a system that executes
  one query. Rejected as disproportionate.

- *SQLAlchemy ORM:* Explicitly prohibited by the requirements brief.

- *asyncpg:* The async psycopg2 alternative. Rejected because FastAPI's synchronous
  route handlers are appropriate for this workload, and introducing async database
  calls would require wrapping in `run_in_executor` or switching to async route
  handlers — complexity with no stated need.

---

## 3. Challenge My Decisions

### Challenge 1 — Single container for API and UI

**Strongest argument against:** Serving static files from a FastAPI application
process means a CPU-bound Python process is handling what should be trivial
file I/O. If the API process becomes unavailable — due to an unhandled exception,
a crash, or a restart — the UI becomes unavailable simultaneously. A separate static
file server would keep the UI accessible even during API outages, giving operations
staff a degraded-but-visible experience rather than a blank page.

**Verdict: Rejected.** The failure mode described — API process unavailable but UI
still useful — does not apply to this system. The UI's sole function is to call
the API. If the API is down, the UI cannot fulfil its purpose regardless of whether
it is still served. The operational simplicity of a two-service stack outweighs a
resilience argument that does not hold for this system's function.

---

### Challenge 2 — New connection per request

**Strongest argument against:** A new TCP connection and TLS handshake (if TLS were
in use) on every request adds latency and Postgres server overhead that a connection
pool would eliminate entirely. Under concurrent load, connection exhaustion becomes
possible — Postgres has a default `max_connections` of 100, and without a pool,
each concurrent request consumes one connection for the full duration of the
request lifecycle.

**Verdict: Rejected for this system.** The challenge is valid in general but does
not apply here. TLS is out of scope. The system serves a small fixed number of
operations staff with no stated concurrent load requirement. Connection exhaustion
requires concurrent connections that this system's use pattern does not produce.
If the scale assumption changes, this is the first decision to revisit.

---

### Challenge 3 — Single shared API key

**Strongest argument against:** A single shared key cannot be selectively revoked.
If the key is compromised — shared in an email, captured in a log, discovered by
an unauthorised party — the entire access layer must be rotated simultaneously for
all users. There is no audit trail: all lookups are indistinguishable from one
another. A per-user key model would allow targeted revocation and per-user
activity logging.

**Verdict: Valid concern, accepted as a known limitation.** This is a genuine
weakness. It is accepted because user management and per-user credentials are
explicitly out of scope in the requirements brief, and this is a training demo
system — not a production access control layer. The limitation must be documented
and understood before any decision to use this design in a higher-stakes context.

---

### Challenge 4 — Init-time seeding via init.sql

**Strongest argument against:** The Postgres `initdb` script mechanism runs only
once — on the first container start with an empty data directory. If the volume
persists across container restarts (the default in Docker Compose), the init script
does not re-run. This means there is no reliable way to reset the database to a
known seed state without explicitly destroying the volume (`docker compose down -v`).
For a system used in iterative testing, this is a meaningful operational constraint
that is easy to forget.

**Verdict: Valid concern, accepted with documentation.** The limitation is real.
The mitigation is operational discipline: the `docker compose down -v` command must
be the documented path to a clean reset. The brief does not require a reset
mechanism beyond cold start, so the limitation is within acceptable scope.

---

### Challenge 5 — Raw psycopg2, no ORM

**Strongest argument against:** Raw SQL with string construction is a SQL injection
attack surface if the parameterisation discipline is ever broken — even once, by
one developer, under time pressure. An ORM's parameterisation is structural and
automatic; psycopg2's requires explicit `%s` placeholders and correct argument
passing on every query. For a system with one query this is manageable, but the
risk scales with the number of queries added in future.

**Verdict: Rejected.** The brief explicitly prohibits ORM use, so the comparison
is constrained. Within the psycopg2 constraint, the risk is real but contained:
the system has one query, parameterisation is enforced in the invariants, and the
code review gate in Phase 6 explicitly checks for f-strings and string concatenation
in SQL. The vulnerability surface is one function.

---

## 4. Key Risks

**R1 — Auth enforcement requires application-level discipline.**
There is no network-boundary enforcement of the authentication requirement.
If a future route is added without the `verify_api_key` dependency, it is
unauthenticated by default and nothing in the infrastructure prevents it.
Mitigation: Claude.md GLOBAL invariant prohibiting unauthenticated routes;
code review gate on every session that touches routing.

**R2 — Internal error leakage is not structurally prevented.**
If psycopg2 raises an unhandled exception, FastAPI's default exception handler
will return a 500 response that may include the exception message. This is an
implementation discipline requirement, not a structural guarantee.
Mitigation: TASK-SCOPED invariant on the connection and lookup functions;
Phase 6 code review gate explicitly checks exception handling.

**R3 — Single shared API key has no revocation granularity.**
A compromised key requires a full rotation with no per-user targeting.
Mitigation: Accepted as a known limitation of the stated scope.
Documented here and in INVARIANTS.md.

**R4 — Volume persistence means seed state is not guaranteed on restart.**
The init.sql seed data populates the database on first run only.
A volume that persists across `docker compose down` (without `-v`) retains
whatever state the database was in — including any manual changes made during
development. Mitigation: Documented clean-reset procedure (`docker compose down -v`).

---

## 5. Key Assumptions

**A1 — Query volume is low.**
The system serves a small, fixed number of internal operations staff. No concurrent
load requirement is stated. The per-request connection design and single-process
FastAPI deployment are premised on this assumption. If volume grows materially,
Decision 2 (no connection pool) is the first architectural decision to revisit.

**A2 — The risk database is read-only at the application level.**
The database contains pre-assessed risk data that does not change during the
lifetime of a deployment. The application has no write path; there is no mechanism
to update risk profiles through this system.

**A3 — The API key is managed and rotated outside the system.**
The system reads `API_KEY` from the environment. Key issuance, rotation, and
distribution are operational concerns outside the system boundary.

**A4 — `risk_factors` is stored as a Postgres array column.**
The JSON response shows `risk_factors` as a list. The schema assumes a native
array column (`TEXT[]`) rather than JSONB or a comma-separated string. This must
be confirmed when the schema is written.

**A5 — A customer with no risk factors is not a valid database state.**
The schema will enforce at least one factor per record. If this assumption is wrong,
the response shape and UI rendering logic must accommodate an empty list.

---

## 6. Open Questions

**OQ1 — `risk_factors` column type.**
The schema design depends on whether factors are stored as `TEXT[]`, `JSONB`, or
another type. This must be resolved before `db/init.sql` is written.
*Resolution required before Phase 3.*

**OQ2 — 401 response body for missing vs. invalid API key.**
The brief shows `{"detail": "Invalid API key"}` but does not specify whether a
missing `X-API-Key` header produces the same message or a different one (e.g.
`"Unauthorized"`). The FastAPI `Header()` dependency raises a 422 by default when
a required header is absent — this behaviour must be explicitly overridden.
*Resolution required before Phase 3.*

**OQ3 — Minimum seed record count per tier.**
The brief says "at least 3 per tier" implicitly through "representative coverage."
The exact minimum count for verification purposes must be stated explicitly so that
the integration check has a concrete pass condition.
*Resolution: minimum 3 records per tier (LOW, MEDIUM, HIGH) — 9 records total minimum.*
*Treat as resolved; confirm at Phase 2.*