WITH recency AS (
  SELECT
    customer_id,
    transaction_date,
    MAX(DATE_ADD(transaction_date, INTERVAL 1 DAY)) OVER() AS snapshot_date,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY transaction_date DESC) as rank 
  FROM {{ ref('fct_transactions') }}
)
SELECT 
  r.customer_id,
  c.customer_name_hashed,
  DATE_DIFF(snapshot_date, transaction_date, DAY) AS customer_recency
FROM recency r
JOIN {{ ref('dim_customers') }} c
  ON r.customer_id = c.customer_id
WHERE rank = 1
ORDER BY c.customer_id, r.transaction_date