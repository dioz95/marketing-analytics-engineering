{% snapshot scd_customers %}

{{ config(
    target_schema="marketing_analytics_dwh",
    strategy="check",
    unique_key='customer_id',
    check_cols=['phone_number_hashed', 'email_hashed', 'city_hashed'],
    invalidate_hard_deletes=True
) }}

SELECT
    customer_id,
    MD5(customer_name) AS customer_name_hashed,
    MD5(gender) AS gender_hashed,
    MD5(phone_number) AS phone_number_hashed,
    CONCAT(TO_BASE64(MD5(SPLIT(email, '@')[0])),'@', SPLIT(email, '@')[1]) AS email_hashed,
    MD5(city) AS city_hashed
FROM {{ ref('src_customers') }}

{% endsnapshot %}