{{
  config(
    materialized = 'table'
  )
}}

WITH raw_drivers AS (
    SELECT 
        RATING          AS rating,
        CITY_ID         AS city_id,
        DRIVER_ID       AS driver_id,
        TO_TIMESTAMP(CREATED_AT) AS created_at_timestamp,
        TO_TIMESTAMP(UPDATED_AT) AS updated_at_timestamp,
        VEHICLE_ID      AS vehicle_id,
        DRIVER_STATUS   AS driver_status,
        ONBOARDING_DATE AS onboarding_date,
    FROM {{ source('beejan_ride_dbt', 'drivers_raw') }}
),
deduplicated AS (
    SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY DRIVER_ID ORDER BY updated_at_timestamp DESC) AS row_num
    FROM raw_drivers
)
SELECT
    rating,
    city_id,
    driver_id,
    created_at_timestamp,
    updated_at_timestamp,
    vehicle_id,
    driver_status,
    onboarding_date
FROM deduplicated
WHERE row_num = 1
