WITH src_transactions AS (
    SELECT 
    *
    FROM {{ ref('src_transactions') }}
),
  unique_product_categories AS (
    SELECT 
        DISTINCT product_category
    FROM src_transactions
)
SELECT 
    {{ dbt_utils.generate_surrogate_key(['product_category']) }} AS product_category_id,
    product_category
FROM unique_product_categories