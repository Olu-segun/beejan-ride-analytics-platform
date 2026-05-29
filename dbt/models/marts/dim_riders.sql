SELECT
    rider_id,
    country,
    referral_code,
    signup_date,
    created_at_timestamp
FROM {{ ref('stg_riders') }}
