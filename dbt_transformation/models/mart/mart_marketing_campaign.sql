SELECT 
  r.metric_time__month as month,
  r.total_revenue,
  m.total_marketing_budget,
  round(mbr.marketing_budget_revenue_ratio, 2) as marketing_budget_revenue_ratio
FROM {{ ref('metrics_total_revenue_by_month') }} r
JOIN {{ ref('metrics_total_marketing_budget_by_month') }} m 
  ON r.metric_time__month = m.metric_time__month 
JOIN {{ ref('metrics_marketing_budget_revenue_ratio_by_month') }} mbr  
  ON r.metric_time__month = mbr.metric_time__month