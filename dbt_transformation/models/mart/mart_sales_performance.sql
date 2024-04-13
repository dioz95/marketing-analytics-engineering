-- This query is directly taken from MetricsFlow with command (with minor adjustment):
-- mf query --metrics total_revenue,count_transactions,count_transacting_customers --group-by metric_time__month,transaction__is_transaction_amount_below_average,product_category_id__product_category --order metric_time__month --start-time 2023-08-01 --end-time 2024-03-01 --explain

SELECT
  COALESCE(subq_19.metric_time__month, subq_29.metric_time__month) AS metric_time__month
  , COALESCE(subq_19.transaction__is_transaction_amount_below_average, subq_29.transaction__is_transaction_amount_below_average) AS transaction__is_transaction_amount_below_average
  , COALESCE(subq_19.product_category_id__product_category, subq_29.product_category_id__product_category) AS product_category_id__product_category
  , COALESCE(MAX(subq_19.total_revenue), 0) AS total_revenue
  , MAX(subq_29.count_transactions) AS count_transactions
  , MAX(subq_29.count_transacting_customers) AS count_transacting_customers
FROM (
  SELECT
    metric_time__month
    , transaction__is_transaction_amount_below_average
    , product_category_id__product_category
    , COALESCE(total_paid, 0) AS total_revenue
  FROM (
    SELECT
      subq_15.metric_time__month AS metric_time__month
      , subq_14.transaction__is_transaction_amount_below_average AS transaction__is_transaction_amount_below_average
      , subq_14.product_category_id__product_category AS product_category_id__product_category
      , subq_14.total_paid AS total_paid
    FROM (
      SELECT
        DATE_TRUNC(date_day, month) AS metric_time__month
      FROM {{ ref('metricflow_time_spine') }} subq_16
      WHERE date_day BETWEEN '2023-08-01' AND '2024-03-31'
      GROUP BY
        metric_time__month
    ) subq_15
    LEFT OUTER JOIN (
      SELECT
        subq_9.metric_time__month AS metric_time__month
        , subq_9.transaction__is_transaction_amount_below_average AS transaction__is_transaction_amount_below_average
        , dim_product_categories_src_10000.product_category AS product_category_id__product_category
        , SUM(subq_9.total_paid) AS total_paid
      FROM (
        SELECT
          DATE_TRUNC(transaction_date, month) AS metric_time__month
          , product_category_id
          , CASE
          WHEN total_paid < AVG(total_paid) OVER() THEN 1
          ELSE 0
        END AS transaction__is_transaction_amount_below_average
          , total_paid
        FROM {{ ref('fct_transactions') }} fct_transactions_src_10000
        WHERE DATE_TRUNC(transaction_date, day) BETWEEN '2023-08-01' AND '2024-03-31'
      ) subq_9
      LEFT OUTER JOIN
        {{ ref('dim_product_categories') }} dim_product_categories_src_10000
      ON
        subq_9.product_category_id = dim_product_categories_src_10000.product_category_id
      GROUP BY
        metric_time__month
        , transaction__is_transaction_amount_below_average
        , product_category_id__product_category
    ) subq_14
    ON
      subq_15.metric_time__month = subq_14.metric_time__month
    WHERE subq_15.metric_time__month BETWEEN '2023-08-01' AND '2024-03-31'
  ) subq_18
) subq_19
FULL OUTER JOIN (
  SELECT
    subq_23.metric_time__month AS metric_time__month
    , subq_23.transaction__is_transaction_amount_below_average AS transaction__is_transaction_amount_below_average
    , dim_product_categories_src_10000.product_category AS product_category_id__product_category
    , SUM(subq_23.count_transactions) AS count_transactions
    , COUNT(DISTINCT subq_23.count_transacting_customers) AS count_transacting_customers
  FROM (
    SELECT
      DATE_TRUNC(transaction_date, month) AS metric_time__month
      , product_category_id
      , CASE
      WHEN total_paid < AVG(total_paid) OVER() THEN 1
      ELSE 0
    END AS transaction__is_transaction_amount_below_average
      , 1 AS count_transactions
      , customer_id AS count_transacting_customers
    FROM {{ ref('fct_transactions') }} fct_transactions_src_10000
    WHERE DATE_TRUNC(transaction_date, day) BETWEEN '2023-08-01' AND '2024-03-31'
  ) subq_23
  LEFT OUTER JOIN
    {{ ref('dim_product_categories') }} dim_product_categories_src_10000
  ON
    subq_23.product_category_id = dim_product_categories_src_10000.product_category_id
  GROUP BY
    metric_time__month
    , transaction__is_transaction_amount_below_average
    , product_category_id__product_category
) subq_29
ON
  (
    subq_19.transaction__is_transaction_amount_below_average = subq_29.transaction__is_transaction_amount_below_average
  ) AND (
    subq_19.product_category_id__product_category = subq_29.product_category_id__product_category
  ) AND (
    subq_19.metric_time__month = subq_29.metric_time__month
  )
GROUP BY
  metric_time__month
  , transaction__is_transaction_amount_below_average
  , product_category_id__product_category
ORDER BY metric_time__month