WITH raw_drivers AS (
    SELECT  *,
            ROW_NUMBER() OVER (PARTITION BY driver_id ORDER BY driver_id DESC) AS row_num
    FROM {{ source('beejan_ride_dbt', 'drivers_raw') }}
),
renamed_columns AS (
    SELECT
        RATING          as rating,
        CITY_ID         as city_id,
        DRIVER_ID       as driver_id,
        TO_TIMESTAMP(CREATED_AT) as created_at_timestamp,
        TO_TIMESTAMP(UPDATED_AT) as updated_at_timestamp,
        VEHICLE_ID      as vehicle_id,
        DRIVER_STATUS   as driver_status,
        ONBOARDING_DATE as onboarding_date
    FROM raw_drivers
    WHERE row_num = 1
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
FROM renamed_columns

