WITH raw_marketing_campaign AS (
    SELECT *
    FROM {{ ref('seeds_marketing_campaign') }}
)
SELECT 
    TRIM(UPPER(campaign)) AS campaign_name,
    start AS start_date,
    `end` AS end_date,
    budget AS marketing_budget
FROM raw_marketing_campaign