# Customer Risk API

**Version:** 1.0  
**Classification:** Training Demo System

---

# Requirements Brief

## The Problem

A financial services client needs to surface customer risk tier information to internal operations staff.

Currently, risk analysts run ad-hoc SQL queries against a Postgres database to answer questions like:

> "What tier is this customer and why?"

This approach is:

- Slow
- Error-prone
- Bypasses access controls

The client wants a lightweight API service that wraps this data with a defined interface, proper authentication, and structured output so downstream tools and staff can query risk status reliably without direct database access.

---

# What Needs to Be Built

A service that:

1. Accepts a `customer_id`
2. Looks up that customer in a pre-loaded risk profile database
3. Returns:
   - The customer's risk tier
   - The factors that drove the assessment

Additionally:

- A simple browser-based interface should allow operations staff to query by customer ID.
- Users should be able to view results without writing code.

---

# Functional Requirements

## API Endpoint

Accept a `customer_id` via HTTP GET and return a structured JSON response containing:

- Customer ID
- Risk Tier (`LOW`, `MEDIUM`, or `HIGH`)
- List of risk factors that contributed to the tier

### Example Response

```json
{
  "customer_id": "CUST123",
  "risk_tier": "HIGH",
  "risk_factors": [
    "Large cash transactions",
    "Sanctions watchlist match"
  ]
}
```

---

## Customer Not Found

When the requested customer ID does not exist in the database:

- Return HTTP `404 Not Found`
- Include a clear error response

### Example

```json
{
  "detail": "Customer not found"
}
```

---

## Authentication

API key authentication must be enforced on **all endpoints**.

Requirements:

- Requests without an API key must be rejected
- Requests with an invalid API key must be rejected
- Return HTTP `401 Unauthorized`

### Example

```json
{
  "detail": "Invalid API key"
}
```

---

## Browser-Based User Interface

A browser-accessible UI must be provided.

Requirements:

- Single HTML page
- Text input for customer ID
- Submit/query button
- Display:
  - Risk result when found
  - Error message when not found or unauthorized

Technology constraints:

- Plain HTML
- Vanilla JavaScript
- No frontend framework

---

## Database

The database must be pre-seeded with representative customer records covering all three risk tiers:

- LOW
- MEDIUM
- HIGH

The database stores already-assessed risk information.

No risk calculations are performed by the application.

---

# Technology Stack (Fixed)

The following technologies are mandatory:

| Component | Technology |
|------------|------------|
| Orchestration | Docker Compose |
| Database | PostgreSQL |
| Backend API | FastAPI (Python 3.11) |
| Database Driver | psycopg2 |
| Frontend | Plain HTML + Vanilla JavaScript |

### Additional Constraints

- No ORM may be used
- Database access must use `psycopg2`

---

# System Constraints

The solution must satisfy all of the following:

## Startup

The entire system must start with:

```bash
docker compose up
```

No manual setup steps are allowed beyond providing an `.env` file.

---

## Local-Only Operation

- No external service calls
- No third-party APIs
- Everything runs locally

---

## UI Hosting

The UI must be served from the same Docker container stack.

Requirements:

- No separate frontend hosting
- No separate deployment target

---

## Read-Only System

The application is strictly read-only.

### Allowed

- Query customer risk information

### Not Allowed

- Create records
- Update records
- Delete records

No write endpoints should exist.

---

# Out of Scope

The following items are explicitly excluded from the project:

## User Management

- User registration
- User accounts
- Role-based access control (RBAC)

---

## Risk Data Modification

- Create risk records
- Update risk records
- Delete risk records

---

## Risk Computation Logic

The application does **not** calculate risk.

Risk values are already assessed and stored in the database.

The system only retrieves and returns existing data.

---

## Production Hardening

The following are out of scope:

- TLS / HTTPS configuration
- Rate limiting
- Enterprise-scale secrets management
- Production security hardening

---

# Summary

Build a Dockerized read-only customer risk lookup system consisting of:

- PostgreSQL database with pre-seeded risk profiles
- FastAPI backend using psycopg2
- API key authentication
- Customer lookup endpoint
- 404 handling for unknown customers
- Simple HTML/JavaScript UI
- Docker Compose orchestration

The entire stack must run locally via:

```bash
docker compose up
```

with no setup beyond supplying an `.env` file.