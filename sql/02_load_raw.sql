-- 02_load_raw.sql
-- Load the two CSV files into the raw tables, then check the row counts.

TRUNCATE raw.casino_transactions;
TRUNCATE raw.sports_transactions;

\copy raw.casino_transactions FROM 'data/raw/Online_casino_DIB.csv' WITH (FORMAT csv, HEADER true)
\copy raw.sports_transactions FROM 'data/raw/Online_sports_DIB.csv' WITH (FORMAT csv, HEADER true)

SELECT 'casino' AS brand, COUNT(*) AS row_count, 138928 AS expected FROM raw.casino_transactions
UNION ALL
SELECT 'sports', COUNT(*), 447853 FROM raw.sports_transactions;