-- This query is directly taken from MetricsFlow with command (with minor adjustment):
-- mf query --metrics total_revenue --group-by customer,customer__customer_name_hashed --order customer --explain
SELECT
  customer AS customer_id
  , customer__customer_name_hashed
  , COALESCE(total_paid, 0) AS customer_monetary
FROM (
  SELECT
    fct_transactions_src_10000.customer_id AS customer
    , dim_customers_src_10000.customer_name_hashed AS customer__customer_name_hashed
    , SUM(fct_transactions_src_10000.total_paid) AS total_paid
  FROM {{ ref('fct_transactions') }} fct_transactions_src_10000
  LEFT OUTER JOIN
    {{ ref('dim_customers') }} dim_customers_src_10000
  ON
    fct_transactions_src_10000.customer_id = dim_customers_src_10000.customer_id
  GROUP BY
    customer
    , customer__customer_name_hashed
) subq_7
ORDER BY customer