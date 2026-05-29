{{
  config(
    materialized = 'table'
  )
}}
WITH raw_riders AS (
    SELECT 
        COUNTRY       AS country,
        RIDER_ID      AS rider_id,
        TO_TIMESTAMP(CREATED_AT) AS created_at_timestamp,
        SIGNUP_DATE   AS signup_date,
        REFERRAL_CODE AS referral_code,
    FROM {{ source('raw', 'riders_raw') }}
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY RIDER_ID ORDER BY (created_at_timestamp) DESC) AS row_num
    FROM raw_riders
)
SELECT
    country,
    rider_id,
    created_at_timestamp,
    signup_date,
    referral_code
FROM deduplicated
WHERE row_num = 1
