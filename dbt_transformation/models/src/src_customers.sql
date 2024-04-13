WITH raw_customers AS (
  SELECT *
  FROM {{ source('loyal-saga-41671', 'raw_customers') }}
)
SELECT
  customer_id,
  TRIM(UPPER(customer_name)) AS customer_name,
  TRIM(UPPER(gender)) AS gender,
  TRIM(REPLACE(phone_number, '-', '')) AS phone_number,
  TRIM(LOWER(email)) AS email,
  TRIM(UPPER(city)) AS city
FROM raw_customers