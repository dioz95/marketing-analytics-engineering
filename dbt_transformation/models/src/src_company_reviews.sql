WITH raw_company_reviews AS (
  SELECT *
  FROM {{ source('loyal-saga-41671', 'raw_company_reviews') }}
)
SELECT 
  TRIM(UPPER(reviewer_name)) AS reviewer_name,
  rating
FROM raw_company_reviews