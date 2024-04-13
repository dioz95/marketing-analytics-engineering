-- This query is directly taken from MetricsFlow with command (with minor adjustment):
-- mf query --metrics count_transactions --group-by customer,customer__customer_name_hashed --order customer --explain
SELECT
  subq_2.customer AS customer_id
  , dim_customers_src_10000.customer_name_hashed AS customer__customer_name_hashed
  , SUM(subq_2.count_transactions) AS customer_frequency
FROM (
  SELECT
    customer_id AS customer
    , 1 AS count_transactions
  FROM {{ ref('fct_transactions') }} fct_transactions_src_10000
) subq_2
LEFT OUTER JOIN
  {{ ref('dim_customers') }} dim_customers_src_10000
ON
  subq_2.customer = dim_customers_src_10000.customer_id
GROUP BY
  customer
  , customer__customer_name_hashed
ORDER BY customer