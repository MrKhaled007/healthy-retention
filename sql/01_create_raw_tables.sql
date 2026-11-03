-- 01_create_raw_tables.sql
-- Raw layer: data stored exactly as delivered, all columns as text.

CREATE SCHEMA IF NOT EXISTS raw;

DROP TABLE IF EXISTS raw.casino_transactions;
CREATE TABLE raw.casino_transactions (
    req_time_utc        TEXT,
    transaction_type    TEXT,
    transaction_amount  TEXT,
    status              TEXT,
    account_identifier  TEXT
);

DROP TABLE IF EXISTS raw.sports_transactions;
CREATE TABLE raw.sports_transactions (
    req_time_utc        TEXT,
    transaction_type    TEXT,
    transaction_amount  TEXT,
    status              TEXT,
    account_identifier  TEXT
);