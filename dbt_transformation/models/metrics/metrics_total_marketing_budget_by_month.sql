-- This query is directly taken from MetricsFlow with command (with minor adjustment):
-- mf query --metrics total_marketing_budget --group- by metric_time__month --order metric_time__month --start-time 2023-08-01 --end-time 2024-02-01 --explain
SELECT
  DATE_TRUNC(start_date, month) AS metric_time__month
  , SUM(marketing_budget) AS total_marketing_budget
FROM {{ ref('fct_marketing_campaign') }} fct_marketing_campaign_src_10000
WHERE DATE_TRUNC(start_date, day) BETWEEN '2023-08-01' AND '2024-02-29'
GROUP BY
  metric_time__month
ORDER BY metric_time__month