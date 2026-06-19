import os
import sys
import requests

BASE_URL = os.environ.get("BASE_URL", "http://localhost:8000")
API_KEY = os.environ.get("API_KEY", "")

INJECTION_CASES = [
    "' OR '1'='1",
    "'; DROP TABLE customer_risk_profiles; --",
    "CUST-001' AND '1'='1",
    "1 UNION SELECT customer_id, risk_tier, risk_factors FROM customer_risk_profiles",
    "CUST-001; SELECT * FROM customer_risk_profiles",
]

EXPECTED_BODY = {"detail": "Customer not found"}

passed = 0
failed = 0

for payload in INJECTION_CASES:
    url = f"{BASE_URL}/customers/{requests.utils.quote(payload, safe='')}"
    try:
        resp = requests.get(url, headers={"X-API-Key": API_KEY}, timeout=10)
        body = resp.json()

        status_ok = resp.status_code == 404
        body_ok = body == EXPECTED_BODY
        no_leak = payload.lower() not in resp.text.lower()

        if status_ok and body_ok and no_leak:
            print(f"PASS  {payload!r}")
            passed += 1
        else:
            reasons = []
            if not status_ok:
                reasons.append(f"status={resp.status_code}")
            if not body_ok:
                reasons.append(f"body={body}")
            if not no_leak:
                reasons.append("injection payload reflected in response")
            print(f"FAIL  {payload!r} — {', '.join(reasons)}")
            failed += 1
    except Exception as exc:
        print(f"FAIL  {payload!r} — exception: {type(exc).__name__}")
        failed += 1

print(f"\n{passed} passed, {failed} failed")
sys.exit(0 if failed == 0 else 1)
