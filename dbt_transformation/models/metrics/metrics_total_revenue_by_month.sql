-- This query is directly taken from MetricsFlow with command (with minor adjustment):
-- mf query --metrics total_revenue --group-by metric_time__month --order metric_time__month --start-time 2023-08-01 --end-time 2024-02-01 --explain
SELECT
  metric_time__month
  , COALESCE(total_paid, 0) AS total_revenue
FROM (
  SELECT
    subq_7.metric_time__month AS metric_time__month
    , subq_6.total_paid AS total_paid
  FROM (
    SELECT
      DATE_TRUNC(date_day, month) AS metric_time__month
    FROM {{ ref('metricflow_time_spine') }} subq_8
    WHERE date_day BETWEEN '2023-08-01' AND '2024-02-29'
    GROUP BY
      metric_time__month
  ) subq_7
  LEFT OUTER JOIN (
    SELECT
      DATE_TRUNC(transaction_date, month) AS metric_time__month
      , SUM(total_paid) AS total_paid
    FROM {{ ref('fct_transactions') }} fct_transactions_src_10000
    WHERE DATE_TRUNC(transaction_date, day) BETWEEN '2023-08-01' AND '2024-02-29'
    GROUP BY
      metric_time__month
  ) subq_6
  ON
    subq_7.metric_time__month = subq_6.metric_time__month
  WHERE subq_7.metric_time__month BETWEEN '2023-08-01' AND '2024-02-29'
) subq_10
ORDER BY metric_time__month