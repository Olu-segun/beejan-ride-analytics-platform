WITH raw_riders AS (
    SELECT  *,
            ROW_NUMBER() OVER (PARTITION BY rider_id ORDER BY rider_id DESC) AS row_num
    FROM {{ source('beejan_ride_dbt', 'riders_raw') }}
),
renamed_columns AS (
    SELECT
        COUNTRY as country,
        RIDER_ID as rider_id,
        TO_TIMESTAMP(CREATED_AT) as created_at,
        SIGNUP_DATE as signup_date,
        REFERRAL_CODE as referral_code
    FROM raw_riders
    WHERE row_num = 1
)
SELECT
        country,
        rider_id,
        created_at, 
        signup_date,
        referral_code
FROM renamed_columns

