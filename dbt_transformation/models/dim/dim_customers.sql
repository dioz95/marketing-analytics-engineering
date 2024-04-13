WITH scd_customers AS (
    SELECT *
    FROM {{ ref('scd_customers') }}
)
SELECT
    customer_id,
    customer_name_hashed,
    gender_hashed,
    phone_number_hashed,
    email_hashed,
    city_hashed
FROM scd_customers
WHERE dbt_valid_to IS NULL