WITH raw_drivers AS (
    SELECT * 
    FROM {{ source('beejan_ride_dbt', 'drivers_raw') }}
)
SELECT
        rating,
        city_id,
        driver_id,
        created_at,
        updated_at,
        vehicle_id,
        driver_status,
        onboarding_date
FROM raw_drivers
