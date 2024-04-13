WITH dim_customers AS (
    SELECT *
    FROM {{ ref('dim_customers') }}
),
    src_company_reviews AS (
    SELECT *
    FROM {{ ref('src_company_reviews') }}
),
    company_reviews_with_cust_id AS (
    SELECT
        c.customer_id,
        cr.rating
    FROM src_company_reviews cr 
    LEFT JOIN dim_customers c 
        ON MD5(cr.reviewer_name) = c.customer_name_hashed
)
SELECT 
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'rating']) }} AS company_review_id,
    *
FROM company_reviews_with_cust_id
