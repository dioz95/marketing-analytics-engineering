SELECT 
  r.customer_id,
  r.customer_name_hashed,
  r.customer_recency,
  f.customer_frequency,
  m.customer_monetary
FROM {{ ref('metrics_customers_recency') }} r 
JOIN {{ ref('metrics_customers_frequency') }} f 
  ON r.customer_id = f.customer_id 
JOIN {{ ref('metrics_customers_monetary') }} m  
  ON r.customer_id = m.customer_id