#!/usr/bin/env bash
set -uo pipefail

BASE_URL="${BASE_URL:-http://localhost:8000}"
API_KEY="${API_KEY:-}"
POSTGRES_USER="${POSTGRES_USER:-}"
POSTGRES_DB="${POSTGRES_DB:-}"

PASSED=0
FAILED=0

pass()   { echo "PASS    $1"; PASSED=$((PASSED + 1)); }
fail()   { echo "FAIL    $1 — $2"; FAILED=$((FAILED + 1)); }
manual() { echo "MANUAL  $1 — $2"; }

http_status() { curl -so /dev/null -w "%{http_code}" "$@"; }
http_body()   { curl -s "$@"; }
db_exec()     { docker compose exec -T db psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -A -c "$1" 2>&1; }

PYTHON=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || true)

echo "=== Customer Risk API — Invariant Verification ==="
echo ""

# ── INV-01: Response values match DB row exactly ────────────────────────────
DB_ROW=$(db_exec \
  "SELECT customer_id, risk_tier, array_to_json(risk_factors)::text FROM customer_risk_profiles WHERE customer_id='CUST-001';" \
  2>/dev/null || true)
DB_ID=$(echo "$DB_ROW" | cut -d'|' -f1 | xargs)
DB_TIER=$(echo "$DB_ROW" | cut -d'|' -f2 | xargs)
DB_FACTORS_JSON=$(echo "$DB_ROW" | cut -d'|' -f3-)
API_RESP=$(http_body -H "X-API-Key: $API_KEY" "$BASE_URL/customers/CUST-001")

export _DB_ID="$DB_ID" _DB_TIER="$DB_TIER" _DB_FACTORS_JSON="$DB_FACTORS_JSON" _API_RESP="$API_RESP"
INV01=$($PYTHON << 'PYEOF'
import json, os
try:
    api = json.loads(os.environ["_API_RESP"])
    db_factors = json.loads(os.environ["_DB_FACTORS_JSON"])
    db_id, db_tier = os.environ["_DB_ID"], os.environ["_DB_TIER"]
    ok = (api["customer_id"] == db_id and
          api["risk_tier"] == db_tier and
          api["risk_factors"] == db_factors)
    print("PASS" if ok else
          f"FAIL: db=({db_id}|{db_tier}|{db_factors}) api=({api.get('customer_id')}|{api.get('risk_tier')}|{api.get('risk_factors')})")
except Exception as e:
    print(f"FAIL: {e}")
PYEOF
)
if [[ "$INV01" == PASS* ]]; then pass "INV-01"; else fail "INV-01" "${INV01#FAIL: }"; fi

# ── INV-02a: Known customer → 200 ───────────────────────────────────────────
STATUS=$(http_status -H "X-API-Key: $API_KEY" "$BASE_URL/customers/CUST-001")
if [[ "$STATUS" == "200" ]]; then pass "INV-02a"; else fail "INV-02a" "expected 200, got $STATUS"; fi

# ── INV-02b: Unknown customer → 404 ─────────────────────────────────────────
STATUS=$(http_status -H "X-API-Key: $API_KEY" "$BASE_URL/customers/CUST-999")
BODY=$(http_body     -H "X-API-Key: $API_KEY" "$BASE_URL/customers/CUST-999")
if [[ "$STATUS" == "404" && "$BODY" == '{"detail":"Customer not found"}' ]]; then
    pass "INV-02b"
else
    fail "INV-02b" "status=$STATUS body=$BODY"
fi

# ── INV-02c + INV-07: DB unreachable → 500 static literal ───────────────────
docker compose stop db > /dev/null 2>&1 || true
sleep 3
STATUS_DOWN=$(http_status -H "X-API-Key: $API_KEY" "$BASE_URL/customers/CUST-001")
BODY_DOWN=$(http_body     -H "X-API-Key: $API_KEY" "$BASE_URL/customers/CUST-001")
docker compose start db > /dev/null 2>&1 || true

for _i in $(seq 1 10); do
    docker compose exec -T db pg_isready -U "$POSTGRES_USER" > /dev/null 2>&1 && break || true
    sleep 2
done

if [[ "$STATUS_DOWN" == "500" && "$BODY_DOWN" == '{"detail":"Internal server error"}' ]]; then
    pass "INV-02c"
else
    fail "INV-02c" "status=$STATUS_DOWN body=$BODY_DOWN"
fi

FIELD_COUNT=$(echo "$BODY_DOWN" | $PYTHON -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
if [[ "$STATUS_DOWN" == "500" && "$BODY_DOWN" == '{"detail":"Internal server error"}' && "$FIELD_COUNT" == "1" ]]; then
    pass "INV-07"
else
    fail "INV-07" "status=$STATUS_DOWN body=$BODY_DOWN fields=$FIELD_COUNT"
fi

# ── INV-03: No write DDL in db/init.sql ─────────────────────────────────────
if grep -qiE "(UPDATE|DELETE|TRUNCATE|CREATE TRIGGER|CREATE FUNCTION)" db/init.sql 2>/dev/null; then
    fail "INV-03" "write DDL found in db/init.sql"
else
    pass "INV-03"
fi

# ── INV-04a: 200 response has exactly 3 fields ──────────────────────────────
BODY=$(http_body -H "X-API-Key: $API_KEY" "$BASE_URL/customers/CUST-001")
FIELD_COUNT=$(echo "$BODY" | $PYTHON -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
if [[ "$FIELD_COUNT" == "3" ]]; then pass "INV-04a"; else fail "INV-04a" "expected 3 fields, got $FIELD_COUNT body=$BODY"; fi

# ── INV-04b: CHECK constraint rejects invalid risk_tier ─────────────────────
DB_OUT=$(db_exec "INSERT INTO customer_risk_profiles VALUES ('TEST-CHK-99','CRITICAL','{\"x\"}');" || true)
if echo "$DB_OUT" | grep -qi "violates check constraint"; then
    pass "INV-04b"
else
    fail "INV-04b" "CHECK constraint not enforced — got: $DB_OUT"
fi

# ── INV-05a: Missing X-API-Key → 401 ────────────────────────────────────────
STATUS=$(http_status "$BASE_URL/customers/CUST-001")
BODY=$(http_body     "$BASE_URL/customers/CUST-001")
if [[ "$STATUS" == "401" && "$BODY" == '{"detail":"Invalid API key"}' ]]; then
    pass "INV-05a"
else
    fail "INV-05a" "status=$STATUS body=$BODY"
fi

# ── INV-05b: Empty X-API-Key → 401 ──────────────────────────────────────────
STATUS=$(http_status -H "X-API-Key: " "$BASE_URL/customers/CUST-001")
BODY=$(http_body     -H "X-API-Key: " "$BASE_URL/customers/CUST-001")
if [[ "$STATUS" == "401" && "$BODY" == '{"detail":"Invalid API key"}' ]]; then
    pass "INV-05b"
else
    fail "INV-05b" "status=$STATUS body=$BODY"
fi

# ── INV-05c: Wrong X-API-Key → 401 ──────────────────────────────────────────
STATUS=$(http_status -H "X-API-Key: wrong-key-xyz" "$BASE_URL/customers/CUST-001")
BODY=$(http_body     -H "X-API-Key: wrong-key-xyz" "$BASE_URL/customers/CUST-001")
if [[ "$STATUS" == "401" && "$BODY" == '{"detail":"Invalid API key"}' ]]; then
    pass "INV-05c"
else
    fail "INV-05c" "status=$STATUS body=$BODY"
fi

# ── INV-06: 401 body does not contain submitted key value ───────────────────
SENTINEL="INV06PROBEVALUE"
BODY=$(http_body -H "X-API-Key: $SENTINEL" "$BASE_URL/customers/CUST-001")
if echo "$BODY" | grep -q "$SENTINEL"; then
    fail "INV-06" "submitted key reflected in response body"
else
    pass "INV-06"
fi

# ── INV-10: SQL injection → 404 ─────────────────────────────────────────────
INJECT=$($PYTHON -c "import urllib.parse; print(urllib.parse.quote(\"' OR '1'='1\", safe=''))")
STATUS=$(http_status -H "X-API-Key: $API_KEY" "$BASE_URL/customers/$INJECT")
BODY=$(http_body     -H "X-API-Key: $API_KEY" "$BASE_URL/customers/$INJECT")
if [[ "$STATUS" == "404" && "$BODY" == '{"detail":"Customer not found"}' ]]; then
    pass "INV-10"
else
    fail "INV-10" "status=$STATUS body=$BODY"
fi

# ── INV-11: depends_on service_healthy in docker-compose.yml ────────────────
if grep -q "service_healthy" docker-compose.yml 2>/dev/null; then
    pass "INV-11"
else
    fail "INV-11" "service_healthy not found in docker-compose.yml"
fi

# ── Manual checks ────────────────────────────────────────────────────────────
echo ""
manual "INV-08" "code review — confirm no requests/httpx/urllib external calls in api/main.py"
manual "INV-09" "browser test — confirm UI renders values verbatim; check index.html for JS transforms"

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "=== Summary: $PASSED passed, $FAILED failed ==="
[[ "$FAILED" -eq 0 ]]
