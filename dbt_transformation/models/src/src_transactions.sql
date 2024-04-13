WITH raw_transactions AS (
  SELECT *
  FROM {{ source('loyal-saga-41671', 'raw_transactions') }}
)
SELECT 
  transaction_id,
  transaction_date,
  TRIM(UPPER(buyer_name)) AS buyer_name,
  TRIM(UPPER(product_category)) AS product_category,
  CAST(REPLACE(SUBSTR(total_price, 3), ',', '') AS FLOAT64) AS total_price_cleansed,
  rating
FROM raw_transactions