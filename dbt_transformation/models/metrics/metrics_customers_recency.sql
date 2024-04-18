SELECT
  customer as customer_id
  , customer__customer_name_hashed
  , SUM(day_differences_transaction_last_transaction) AS customer_recency
FROM (
  SELECT
    subq_2.customer AS customer
    , subq_2.transaction__rank_customer_latest_transaction AS transaction__rank_customer_latest_transaction
    , dim_customers_src_10000.customer_name_hashed AS customer__customer_name_hashed
    , subq_2.day_differences_transaction_last_transaction AS day_differences_transaction_last_transaction
  FROM (
    SELECT
      customer_id AS customer
      , ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY transaction_date DESC) AS transaction__rank_customer_latest_transaction
      , DATE_DIFF(MAX(DATE_ADD(transaction_date, INTERVAL 1 DAY)) OVER(), transaction_date, DAY) AS day_differences_transaction_last_transaction
    FROM {{ ref('fct_transactions') }} fct_transactions_src_10000
  ) subq_2
  LEFT OUTER JOIN
    {{ ref('dim_customers') }} dim_customers_src_10000
  ON
    subq_2.customer = dim_customers_src_10000.customer_id
) subq_6
WHERE transaction__rank_customer_latest_transaction = 1
GROUP BY
  customer
  , customer__customer_name_hashed
ORDER BY customer