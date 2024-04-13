-- This query is directly taken from MetricsFlow with command (with minor adjustment):
-- mf query --metrics marketing_budget_revenue_ratio group-by metric_time__month --order metric_time__month --start-time 2023-08-01 --end-time 2024-02-01 --explain
SELECT
  metric_time__month
  , CAST(total_marketing_budget AS FLOAT64) / CAST(NULLIF(total_revenue, 0) AS FLOAT64) AS marketing_budget_revenue_ratio
FROM (
  SELECT
    COALESCE(subq_9.metric_time__month, subq_19.metric_time__month) AS metric_time__month
    , MAX(subq_9.total_marketing_budget) AS total_marketing_budget
    , COALESCE(MAX(subq_19.total_revenue), 0) AS total_revenue
  FROM (
    SELECT
      DATE_TRUNC(start_date, month) AS metric_time__month
      , SUM(marketing_budget) AS total_marketing_budget
    FROM {{ ref('fct_marketing_campaign') }} fct_marketing_campaign_src_10000
    WHERE DATE_TRUNC(start_date, day) BETWEEN '2023-08-01' AND '2024-02-29'
    GROUP BY
      metric_time__month
  ) subq_9
  FULL OUTER JOIN (
    SELECT
      metric_time__month
      , COALESCE(total_paid, 0) AS total_revenue
    FROM (
      SELECT
        subq_15.metric_time__month AS metric_time__month
        , subq_14.total_paid AS total_paid
      FROM (
        SELECT
          DATE_TRUNC(date_day, month) AS metric_time__month
        FROM {{ ref('metricflow_time_spine') }} subq_16
        WHERE date_day BETWEEN '2023-08-01' AND '2024-02-29'
        GROUP BY
          metric_time__month
      ) subq_15
      LEFT OUTER JOIN (
        SELECT
          DATE_TRUNC(transaction_date, month) AS metric_time__month
          , SUM(total_paid) AS total_paid
        FROM {{ ref('fct_transactions') }} fct_transactions_src_10000
        WHERE DATE_TRUNC(transaction_date, day) BETWEEN '2023-08-01' AND '2024-02-29'
        GROUP BY
          metric_time__month
      ) subq_14
      ON
        subq_15.metric_time__month = subq_14.metric_time__month
      WHERE subq_15.metric_time__month BETWEEN '2023-08-01' AND '2024-02-29'
    ) subq_18
  ) subq_19
  ON
    subq_9.metric_time__month = subq_19.metric_time__month
  GROUP BY
    metric_time__month
) subq_20
ORDER BY metric_time__month