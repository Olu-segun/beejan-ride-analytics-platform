WITH raw_riders AS (
    SELECT * 
    FROM {{ source('beejan_ride_dbt', 'riders_raw') }}
)

SELECT
        country,
        rider_id,
        created_at,
        signup_date,
        referral_code
FROM raw_riders
