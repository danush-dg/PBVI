# INVARIANTS.md — Customer Risk API

## Changelog
| Version | Date | Author | Change |
|---|---|---|---|
| v1.0 | 2026-06-19 | Engineer | Greenfield — Initial. 11 invariants: 9 original + INV-10 (SQL injection) + INV-11 (startup ordering). All challenge dispositions applied. |

---

## Authorship Mode: ASSISTED
Structural and data invariants (INV-01 through INV-09, INV-11): CD-drafted, engineer signed off.
Domain invariants (INV-10): engineer-authored.
All invariants engineer-signed-off.

---

## INV-01 — Data Correctness

**Condition:** The value of `risk_tier` and every element of `risk_factors` returned
in the API response must exactly match the values stored in the database row for that
`customer_id`. The order of elements in the `risk_factors` array must match the order
in which they are stored in the database. No transformation, normalisation,
capitalisation change, reordering, or substitution is permitted between the database
read and the JSON response.

**Category:** Data
**Scope:** GLOBAL
**Authorship:** CD-drafted, engineer signed off

**Why it matters:** Operations staff make risk decisions based on what this API
returns. If the response diverges from what the database holds — even in ordering —
decisions are made on data that does not reflect the analysts' assessment. The system
becomes a distortion layer rather than an access layer, and the distortion is silent.

**Enforcement points:**
- The SQL SELECT query must return columns in a defined order
- The FastAPI response model must map database columns directly without transformation
- No sorting, filtering, or reformatting in the route handler or response serialiser
- Phase 6 code review: confirm no mapping logic between DB result and response fields

**Failure mode:**
- Violation observable state: API response contains a `risk_tier` or `risk_factors`
  value that differs from the database row, or factors appear in a different order
- Detection point: direct comparison test — query DB for a known customer, call API,
  assert field-by-field and element-by-element equality including order
- Blast radius: every lookup is potentially wrong; staff decisions are based on
  corrupted output with no visible indication of the error

---

## INV-02 — Existence Mapping

**Condition:** A `customer_id` that exists in the database must return HTTP 200 with
a complete, well-formed response body. A `customer_id` that does not exist must return
HTTP 404 with body `{"detail": "Customer not found"}` and no other data. When the
database is unreachable or returns an error during lookup, the API must return HTTP 500
with body `{"detail": "Internal server error"}` and no customer data. No response code
or body outside these three defined conditions is permitted.

**Category:** Data
**Scope:** GLOBAL
**Authorship:** CD-drafted, engineer signed off

**Why it matters:** A 404 for a real customer causes staff to conclude the customer
has no risk profile — a false negative that could allow a high-risk customer to pass
unscrutinised. Any non-404 response for a non-existent customer fabricates a result
where none exists. An unhandled database error that returns a partial or ambiguous
response leaves the caller with no reliable signal.

**Enforcement points:**
- Route handler must use parameterised query and check `rowcount` or `fetchone` result
- Database error path must be explicitly caught and mapped to 500
- FastAPI exception handler must not pass database exceptions through unmodified
- Phase 6 code review: confirm all three branches are explicitly handled

**Failure mode:**
- Violation observable state: a real customer receives 404; a ghost customer receives
  anything other than 404; a DB failure produces a response other than 500 with the
  defined body
- Detection point: three test cases — known customer ID (assert 200), unknown customer
  ID (assert 404 + body), DB container stopped (assert 500 + body)
- Blast radius: false negatives on real customers directly impair operational
  decisions; DB error leakage violates INV-07 simultaneously

---

## INV-03 — Mutability

**Condition:** The application must never issue any SQL statement that modifies the
database at runtime. Only `SELECT` statements are permitted from the application
process. No `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, or DDL statement may be
executed by the application at runtime. The database schema must define no triggers
that fire write operations as a side effect of `SELECT` queries.

**Category:** Structural
**Scope:** GLOBAL
**Authorship:** CD-drafted, engineer signed off

**Why it matters:** The database is the sole source of truth for pre-assessed risk
data. Any write from the application layer corrupts that source of truth. Because
the system has no audit trail for runtime writes, corruption would be silent and
undetectable. A trigger-fired write on SELECT is particularly dangerous because it
satisfies a surface-level "no write statements" check while still mutating the
database.

**Enforcement points:**
- `db/init.sql` must contain no trigger definitions — confirmed at schema authoring time
- Application code must contain no write SQL statements — confirmed at Phase 6 code review
- No write endpoints exist in the route definitions
- Phase 6 code review: grep for `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE` in all
  Python source files

**Failure mode:**
- Violation observable state: database state changes after an API call that should
  be read-only; row counts change; data values are altered
- Detection point: record DB state before request, issue request, record DB state
  after — assert no difference in any table
- Blast radius: risk data integrity is compromised; because there is no write audit
  trail, the corruption may not be discovered until a downstream decision is made on
  wrong data

---

## INV-04a — Response Shape (Application Layer)

**Condition:** Every HTTP 200 response from the customer lookup endpoint must be a
JSON object containing exactly three fields: `customer_id` (string), `risk_tier`
(string), and `risk_factors` (array of strings). No additional fields may be present.
The exact field set must be verified — presence of the three required fields is
necessary but not sufficient; absence of any additional fields is equally required.
The `risk_factors` array must contain at least one element.

**Category:** Structural
**Scope:** GLOBAL
**Authorship:** CD-drafted, engineer signed off

**Why it matters:** Downstream tools and scripts that consume the API break on
inconsistent structure. An extra field — such as an internal database row ID — leaks
schema details to callers. A variable shape makes the API contract untrustworthy.
An empty `risk_factors` array violates the data model assumption that every stored
risk profile has at least one contributing factor.

**Enforcement points:**
- FastAPI response model must use `response_model` with a Pydantic schema that
  excludes extra fields (`model_config = ConfigDict(extra='forbid')` or equivalent)
- Phase 6 code review: confirm response model does not pass through raw database row
  objects or dictionaries with uncontrolled keys
- Test must assert exact field set — not just presence of required fields

**Failure mode:**
- Violation observable state: response contains a fourth field; response contains
  `risk_factors: []`; response contains a non-string element in `risk_factors`
- Detection point: parse response JSON, assert `set(response.keys()) == {"customer_id",
  "risk_tier", "risk_factors"}`, assert `len(risk_factors) >= 1`, assert all elements
  are strings
- Blast radius: schema leakage via extra fields; broken downstream consumers;
  empty factors array misrepresents the risk assessment

---

## INV-04b — Response Shape (Data Quality Layer)

**Condition:** The value of `risk_tier` stored in the database must be one of exactly
three values: `LOW`, `MEDIUM`, or `HIGH`. No other value is permitted. This constraint
is enforced at the database schema level via a `CHECK` constraint and is not enforced
by the application at runtime.

**Category:** Data
**Scope:** TASK-SCOPED — enforced at schema authoring time (Session 1, Task 1.2)
**Authorship:** CD-drafted, engineer signed off

**Why it matters:** If an invalid tier value enters the database, the application
returns it verbatim (per INV-01). The caller receives a `risk_tier` value that
operations staff and downstream tools do not recognise. The schema constraint is the
only enforcement point — it must be present before any data is inserted.

**Enforcement points:**
- `db/init.sql` must include `CHECK (risk_tier IN ('LOW', 'MEDIUM', 'HIGH'))` on the
  schema definition
- Phase 6 code review of `db/init.sql`: confirm CHECK constraint is present
- Verification: attempt to insert a row with an invalid tier value — confirm Postgres
  rejects it

**Failure mode:**
- Violation observable state: a row with `risk_tier = 'CRITICAL'` or any other
  non-enumerated value exists in the database
- Detection point: attempt INSERT with invalid tier value, assert Postgres raises
  constraint violation
- Blast radius: invalid tier propagates to API response verbatim; downstream tools
  fail on unrecognised value; staff see an unexpected tier label with no explanation

---

## INV-05 — Authentication

**Condition:** Every request to any endpoint except `GET /health` must be rejected
with HTTP 401 and body `{"detail": "Invalid API key"}` if the `X-API-Key` header is
absent, empty, or does not exactly match the value of the `API_KEY` environment
variable. No customer data, partial response, or internal detail may be returned to
any caller that fails this check. The health check endpoint (`GET /health`) is the
sole unauthenticated surface — it must return only `{"status": "ok"}` with HTTP 200
and must expose no customer data, no system internals, and no information about
database state.

**Category:** Structural
**Scope:** GLOBAL
**Authorship:** CD-drafted, engineer signed off

**Why it matters:** Risk tier and factor data is sensitive financial risk intelligence.
If any endpoint bypasses the auth check, the entire access control model collapses.
A missing-header request that returns 422 (FastAPI's default for a missing required
header) instead of 401 is an auth bypass in the sense that the caller learns the
endpoint exists and accepts the header. An empty-string key that is treated as
"present" rather than "invalid" is a bypass vector.

**Enforcement points:**
- FastAPI dependency `verify_api_key` must be applied to all routes except `GET /health`
- The dependency must explicitly handle: missing header → 401, empty string → 401,
  wrong value → 401
- FastAPI's default 422 for missing required headers must be overridden to 401
- Phase 6 code review: confirm dependency is applied to every non-health route;
  confirm no route bypasses it via direct DB access

**Failure mode:**
- Violation observable state: a request without `X-API-Key` returns anything other
  than 401 with the defined body; a request with an empty string key returns anything
  other than 401; an authenticated request to `/health` returns customer data
- Detection point: four test cases — missing header (assert 401 + body), empty string
  key (assert 401 + body), wrong key (assert 401 + body), correct key (assert 200);
  unauthenticated GET /health (assert 200 + `{"status": "ok"}` only)
- Blast radius: full data exposure to any caller who can reach the API's network
  address; no per-user revocation path exists

---

## INV-06 — Credential Handling

**Condition:** The value of the `API_KEY` environment variable must never appear in
any HTTP response body, HTTP response header, application log output, or Docker
container log output (`docker compose logs`). The 401 response body must use the
exact static string literal `{"detail": "Invalid API key"}` — never an f-string,
format string, or any interpolation that incorporates any portion of the submitted
key or the stored key. FastAPI's default request logging must be confirmed to not
include request header values, or must be suppressed or replaced.

**Category:** Structural
**Scope:** GLOBAL
**Authorship:** CD-drafted, engineer signed off

**Why it matters:** The API key is the sole access control mechanism and is shared
across all operations staff. A single exposure — in a response body, a log file, or
a container log — compromises all access simultaneously. Because the key is shared,
there is no selective revocation: a key rotation affects every user. Log exposure is
particularly insidious because logs are often shared for debugging without awareness
of what they contain.

**Enforcement points:**
- `verify_api_key` function must use a static string literal for the 401 detail —
  confirmed at Phase 6 code review (grep for f-string or `.format` near HTTPException)
- FastAPI/uvicorn access log format must be confirmed to not include header values
- `docker compose logs api` output must be inspected after a test request to confirm
  no key value appears
- Phase 6 code review: confirm `API_KEY` is read from environment and never assigned
  to a variable that is logged or returned

**Failure mode:**
- Violation observable state: `docker compose logs api` contains the API key value;
  a 401 response body contains any portion of the submitted or stored key
- Detection point: submit a request with a known wrong key value; inspect 401 response
  body (assert exact literal match); inspect container logs (assert key value absent)
- Blast radius: key exposure; total access compromise with no targeted revocation path;
  all operations staff must be notified and key rotated immediately

---

## INV-07 — Error Surfaces

**Condition:** No information about the system's internal implementation,
dependencies, or infrastructure may appear in any HTTP response body under any
circumstances. This is a principle, not a list: if a piece of information would help
an attacker understand how the system is built, where it runs, or what it depends on,
it must not appear in a response. All exceptions raised below the FastAPI route
handler — including psycopg2 exceptions, connection errors, and Python runtime errors
— must be caught by a FastAPI exception handler registered at the application level
and replaced with a generic HTTP 500 response before reaching the caller.

**Category:** Structural
**Scope:** GLOBAL
**Authorship:** CD-drafted, engineer signed off

**Why it matters:** Internal detail in an error response is reconnaissance. A
psycopg2 error message reveals the database driver. A connection string reveals the
host and credentials. A stack trace reveals the file structure and module names. For
operations staff, raw exceptions are also unactionable — they see a technical error
they cannot interpret or report meaningfully.

**Enforcement points:**
- A FastAPI exception handler must be registered at application startup covering all
  unhandled exceptions (`@app.exception_handler(Exception)`)
- The handler must return a fixed HTTP 500 response — no exception detail, no
  message interpolation
- Phase 6 code review: confirm the handler is registered and covers the psycopg2
  exception hierarchy
- Test: stop the `db` container while the API is running; send an authenticated
  request; assert 500 response with no internal detail in body

**Failure mode:**
- Violation observable state: any HTTP response body contains a class name, module
  path, file path, hostname, port number, connection string, or stack trace
- Detection point: trigger a DB connection failure; assert response body equals
  `{"detail": "Internal server error"}` exactly; assert no additional fields
- Blast radius: internal topology exposed to caller; subsequent targeted attacks
  become significantly easier; trust in the system is destroyed

---

## INV-08 — Operational Isolation

**Condition:** The application must make no network calls to any host outside the
Docker Compose internal network at any time during its operation. Prohibited
operations include: outbound TCP connections to external hosts, DNS lookups for
external hostnames, HTTP calls to third-party APIs, and any import of a library
that initiates network activity on import. All I/O is limited to inbound HTTP
requests from the host network and outbound TCP connections to the `db` service
on the internal Compose network.

**Category:** Structural
**Scope:** GLOBAL
**Authorship:** CD-drafted, engineer signed off

**Why it matters:** An outbound call introduces an external dependency — the system's
behaviour becomes contingent on network availability the brief prohibits. More
critically, an outbound call is a potential data exfiltration vector: customer risk
data or credentials could be sent to an external destination without the operator's
knowledge. DNS lookups for external hosts are included because a lookup confirms the
system is attempting external contact even if the TCP connection never completes.

**Enforcement points:** MANUAL — this invariant cannot be verified by observing API
behaviour alone. Verification requires:
- Static code review: confirm no `requests`, `httpx`, `urllib`, `socket` calls to
  external hosts in any source file
- Confirm all imported libraries are local-only (psycopg2, FastAPI, uvicorn — none
  initiate external network calls on import)
- Docker Compose network configuration review: confirm no external network definitions

**Failure mode:**
- Violation observable state: network monitoring shows outbound TCP connections or
  DNS queries to non-Compose hosts during API operation
- Detection point: code review (primary); optionally, run API with external network
  disabled at the Docker level and confirm all functionality still works
- Blast radius: external dependency makes the system unreliable in air-gapped or
  restricted environments; exfiltration risk if call carries customer data

---

## INV-09 — UI Fidelity

**Condition:** The browser UI must render the values of `customer_id`, `risk_tier`,
and `risk_factors` exactly as returned in the raw API JSON response. No label
mapping, capitalisation transformation, filtering, sorting, reformatting, or
interpolation of any kind is permitted in the JavaScript rendering logic for any of
these three fields. The text visible in the DOM for each field must be an exact
string match of the corresponding value in the API response. Empty-string elements
in `risk_factors` are a data quality violation governed by INV-04a and must not be
silently filtered by the UI — if present, they must be rendered as received.

**Category:** Structural
**Scope:** GLOBAL
**Authorship:** CD-drafted, engineer signed off

**Why it matters:** The UI is the surface operations staff interact with. If the UI
transforms any value — even a cosmetic capitalisation change on `risk_tier` — staff
see data that does not match the database. Because the API itself would appear correct
under testing, a UI-layer transformation is the hardest failure mode to detect. It
can persist unnoticed through all API-level verification and only surfaces when
someone compares what the browser shows against the database directly.

**Enforcement points:**
- Phase 6 code review of `index.html` JavaScript: confirm no switch statements, label
  maps, `.toLowerCase()`, `.toUpperCase()`, `.replace()`, sort calls, or filter calls
  on `risk_tier`, `risk_factors`, or `customer_id` values before rendering
- Playwright test: call API with known customer ID, capture raw JSON response, load
  UI, submit same customer ID, assert DOM text for each field is an exact string match
  of the corresponding API response value

**Failure mode:**
- Violation observable state: DOM text for `risk_tier` reads "High" when API returns
  "HIGH"; a factor is absent from the rendered list; `customer_id` is formatted
  differently in the UI than in the API response
- Detection point: Playwright assertion comparing raw API response values against
  rendered DOM text for each of the three fields
- Blast radius: staff make decisions on visually transformed data with no indication
  the transformation occurred; because the API is correct, standard API testing does
  not catch this

---

## INV-10 — SQL Injection Prevention

**Condition:** The `customer_id` path parameter must be passed to the database query
exclusively as a psycopg2 parameterised query argument — never via string
concatenation, f-string interpolation, or `.format()` construction. A request
containing SQL metacharacters in the `customer_id` value (such as `'`, `--`, `;`,
`OR`, `=`) must return either HTTP 401 (if unauthenticated) or HTTP 404 (if
authenticated and no matching row exists) — never a data response, never a 500 from
a malformed query, and never any database error detail.

**Category:** Domain
**Scope:** TASK-SCOPED — enforced at Session 3, Task implementing the customer lookup query
**Authorship:** Engineer-authored

**Why it matters:** The customer ID is user-supplied input that is passed directly
into a SQL query. An unparameterised query allows an attacker to manipulate the SQL
structure — extracting rows they are not entitled to, bypassing the existence check,
or in the worst case issuing write statements that INV-03 prohibits at the
application level but that a SQL injection can circumvent entirely. This is the
primary attack surface for a system that accepts user input and executes SQL.

**Enforcement points:**
- The lookup query must use psycopg2's `%s` placeholder syntax with a separate
  arguments tuple — never string construction of any kind
- Phase 6 code review: confirm the query string is a static literal; confirm the
  customer ID is passed as the second argument to `cursor.execute()`
- Test: submit known SQL injection strings as customer ID values; assert 404 response
  with no data; assert no 500 or database error

**Failure mode:**
- Violation observable state: a request with `customer_id = "' OR '1'='1"` returns
  a 200 with customer data; a malformed SQL string causes a 500 with database error
  detail
- Detection point: parameterised injection test cases — submit at least three known
  injection patterns; assert 404 for each with authenticated request
- Blast radius: complete data exposure — all customer records accessible to any
  authenticated caller regardless of which customer ID they are entitled to query;
  INV-03 also violated if the injection enables a write path

---

## INV-11 — Startup Dependency Ordering

**Condition:** The API container must not accept inbound HTTP requests until the
`db` Compose service has passed its healthcheck. This ordering must be enforced by
a `depends_on: condition: service_healthy` declaration in `docker-compose.yml` and
a `HEALTHCHECK` instruction on the `db` service. The healthcheck must verify that
Postgres is accepting connections — not merely that the container process has started.

**Category:** Structural
**Scope:** TASK-SCOPED — enforced at Session 1, Task authoring docker-compose.yml
**Authorship:** CD-drafted, engineer signed off

**Why it matters:** If the API starts before Postgres has finished initialising and
applying the schema, any lookup request during that window results in a connection
error. Depending on how that error is handled, it produces either a silent 500 (if
INV-07 is working) or an internal error leak (if it is not). The race condition is
intermittent — it appears only on first cold start or after a volume reset — making
it difficult to reproduce and diagnose after the fact.

**Enforcement points:**
- `docker-compose.yml` must include `HEALTHCHECK` on the `db` service using
  `pg_isready` or an equivalent Postgres-aware check
- `api` service must declare `depends_on: db: condition: service_healthy`
- Verification: `docker compose up` from cold start; confirm API container does not
  begin serving requests before DB healthcheck passes (observable in compose log
  output)

**Failure mode:**
- Violation observable state: API container begins accepting requests and returning
  500 errors before the database is ready; first requests on cold start fail
  intermittently
- Detection point: cold-start integration test — `docker compose up`, immediately
  send authenticated request, assert 200 (not 500); repeat three times to confirm
  no race
- Blast radius: intermittent failures on cold start; if INV-07 is also incomplete,
  connection error detail leaks to caller; unreliable system state at the moment
  operations staff most need it to work

---

## Invariant Index

| ID | Category | Scope | Description |
|---|---|---|---|
| INV-01 | Data | GLOBAL | Response values and factor order match database exactly |
| INV-02 | Data | GLOBAL | 200/404/500 mapping — defined response for every database outcome |
| INV-03 | Structural | GLOBAL | No write SQL at runtime; no write triggers in schema |
| INV-04a | Structural | GLOBAL | Exactly three fields in 200 response; risk_factors non-empty |
| INV-04b | Data | TASK-SCOPED | risk_tier CHECK constraint — LOW/MEDIUM/HIGH only |
| INV-05 | Structural | GLOBAL | 401 on missing/empty/wrong key; health check is sole unauthenticated surface |
| INV-06 | Structural | GLOBAL | API key never in response, header, app log, or container log |
| INV-07 | Structural | GLOBAL | No internal implementation detail in any response — principle, not list |
| INV-08 | Structural | GLOBAL | No network calls outside Compose internal network — MANUAL verification |
| INV-09 | Structural | GLOBAL | UI renders all three response fields verbatim — no transformation |
| INV-10 | Domain | TASK-SCOPED | Parameterised queries only — no string construction of SQL |
| INV-11 | Structural | TASK-SCOPED | API does not accept requests before DB healthcheck passes |

**GLOBAL invariants (Claude.md Section 2 candidates):** INV-01, INV-02, INV-03, INV-04a, INV-05, INV-06, INV-07, INV-08, INV-09 — nine candidates against a five-invariant ceiling. Requires engineer triage before Claude.md is produced. See note below.

---

## GLOBAL Invariant Ceiling Note

Claude.md Section 2 permits a maximum of five GLOBAL invariants. The current set
has nine GLOBAL candidates. Before Phase 5, you must triage these to five by either:
- Reclassifying lower-priority globals as TASK-SCOPED (embedded in task prompts)
- Merging invariants that share a single enforcement point
- Confirming which five represent the highest harm if violated

Suggested triage basis — harm and detectability ranking:
1. INV-05 — Authentication (full data exposure, no detection path)
2. INV-03 — Mutability (silent data corruption)
3. INV-07 — Error surfaces (structural principle, covers all routes)
4. INV-01 — Data correctness (silent distortion of every lookup)
5. INV-06 — Credential handling (key exposure, no revocation)

Candidates for reclassification to TASK-SCOPED: INV-02 (enforced at the lookup
route handler — single file), INV-04a (enforced at the response model — single
Pydantic class), INV-08 (MANUAL — code review only, not runtime enforcement),
INV-09 (enforced entirely in index.html JavaScript — single file).