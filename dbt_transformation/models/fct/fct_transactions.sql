{{
  config(
    materialized = 'incremental',
    on_schema_change='fail'
    )
}}

{# {{
  config(
    materialized = 'table'
    )
}} #}

WITH src_transactions AS (
  SELECT *
  FROM {{ ref('src_transactions') }}
),
  dim_customers AS (
    SELECT *
    FROM {{ ref('dim_customers') }}
),
  dim_product_category AS (
    SELECT *
    FROM {{ ref('dim_product_categories') }}
)
SELECT
  t.transaction_id,
  t.transaction_date,
  c.customer_id,
  pc.product_category_id,
  CASE 
    WHEN IS_NAN(t.total_price_cleansed) THEN NULL 
    ELSE t.total_price_cleansed 
  END AS total_paid,
  t.rating
FROM src_transactions t 
LEFT JOIN dim_customers c 
  ON MD5(t.buyer_name) = c.customer_name_hashed
LEFT JOIN dim_product_category pc 
  ON t.product_category = pc.product_category
WHERE t.transaction_date IS NOT NULL 
{% if is_incremental() %}
  {% if var("start_date", False) and var("end_date", False) %}
    {{ log('Loading ' ~ this ~ ' incrementally (start_date: ' ~ var("start_date") ~ ', end_date: ' ~ var("end_date") ~ ')', info=True) }}
    AND t.transaction_date >= '{{ var("start_date") }}'
    AND t.transaction_date < '{{ var("end_date") }}'
  {% else %}
    AND t.transaction_date > (select max(t.transaction_date) from {{ this }})
    {{ log('Loading ' ~ this ~ ' incrementally (all missing dates)', info=True)}}
  {% endif %}
{% endif %}