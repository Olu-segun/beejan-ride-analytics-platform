{{
  config(
    materialized = 'table',
    unique_key = 'trip_id',
    )
}}

WITH raw_trips AS (
    SELECT  *,
            ROW_NUMBER() OVER (PARTITION BY trip_id ORDER BY trip_id DESC) AS row_num
    FROM {{ source('beejan_ride_dbt', 'trips_raw') }}
),
renamed_columns AS (
    SELECT
        STATUS as status,
        CITY_ID as city_id,
        TRIP_ID as trip_id,
        RIDER_ID as rider_id,
        DRIVER_ID as driver_id,
        TO_TIMESTAMP(PICKUP_AT) as pickup_at_timestamp,
        TO_TIMESTAMP(CREATED_AT) as created_at_timestamp,
        TO_TIMESTAMP(DROPOFF_AT) as dropoff_at_timestamp,
        TO_TIMESTAMP(UPDATED_AT) as updated_at_timestamp,
        TO_TIMESTAMP(REQUESTED_AT) as requested_at_timestamp,
        VEHICLE_ID as vehicle_id,
        ACTUAL_FARE as actual_fare,
        IS_CORPORATE as is_corporate,
        ESTIMATED_FARE as estimated_fare,
        PAYMENT_METHOD as payment_method,
        SURGE_MULTIPLIER as surge_multiplier
FROM raw_trips
WHERE row_num = 1
)
SELECT
        status,
        city_id,
        trip_id,
        rider_id,
        driver_id,
        pickup_at_timestamp,
        created_at_timestamp,
        dropoff_at_timestamp,
        updated_at_timestamp,
        requested_at_timestamp,
        vehicle_id,
        actual_fare,
        is_corporate,
        estimated_fare,
        payment_method,
        surge_multiplier
FROM renamed_columns

{% if is_incremental() %}
    WHERE trip_id >= (SELECT MAX(trip_id) FROM {{ this }})
{% endif %}
