CREATE TABLE IF NOT EXISTS customer_risk_profiles (
    customer_id  VARCHAR(50) PRIMARY KEY,
    risk_tier    VARCHAR(10) NOT NULL CHECK (risk_tier IN ('LOW', 'MEDIUM', 'HIGH')),
    risk_factors TEXT[]      NOT NULL
);

INSERT INTO customer_risk_profiles (customer_id, risk_tier, risk_factors) VALUES
    ('CUST-001', 'LOW',    ARRAY['low credit utilisation', 'stable employment history']),
    ('CUST-002', 'LOW',    ARRAY['long account tenure', 'no missed payments']),
    ('CUST-003', 'LOW',    ARRAY['diversified portfolio', 'consistent income']),
    ('CUST-004', 'MEDIUM', ARRAY['recent address change', 'moderate debt-to-income ratio']),
    ('CUST-005', 'MEDIUM', ARRAY['short credit history', 'irregular income']),
    ('CUST-006', 'MEDIUM', ARRAY['multiple recent enquiries', 'partial payment history']),
    ('CUST-007', 'HIGH',   ARRAY['default on prior loan', 'high credit utilisation', 'county court judgement']),
    ('CUST-008', 'HIGH',   ARRAY['bankruptcy filing', 'multiple delinquencies']),
    ('CUST-009', 'HIGH',   ARRAY['identity verification failed', 'account flagged for fraud', 'chargebacks recorded']);
