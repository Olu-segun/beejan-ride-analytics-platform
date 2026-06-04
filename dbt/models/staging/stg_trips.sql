{{
  config(
    materialized='incremental',
    unique_key='trip_id',
    on_schema_change='fail'
  )
}}

WITH raw_trips AS (

    SELECT
        STATUS AS trip_status,
        CITY_ID AS city_id,
        TRIP_ID AS trip_id,
        RIDER_ID AS rider_id,
        DRIVER_ID AS driver_id,
        TO_TIMESTAMP(PICKUP_AT) AS pickup_at_timestamp,
        TO_TIMESTAMP(CREATED_AT) AS created_at_timestamp,
        TO_TIMESTAMP(DROPOFF_AT) AS dropoff_at_timestamp,
        TO_TIMESTAMP(UPDATED_AT) AS updated_at_timestamp,
        TO_TIMESTAMP(REQUESTED_AT) AS requested_at_timestamp,
        VEHICLE_ID AS vehicle_id,
        ACTUAL_FARE AS actual_fare,
        IS_CORPORATE AS is_corporate,
        ESTIMATED_FARE AS estimated_fare,
        PAYMENT_METHOD AS payment_method,
        SURGE_MULTIPLIER AS surge_multiplier
    FROM {{ source('raw', 'trips_raw') }}

    {% if is_incremental() %}
    WHERE (updated_at_timestamp) >= (SELECT COALESCE(MAX(updated_at_timestamp),'1900-01-01')
    FROM {{ this }}
    )
    {% endif %}

),
deduplicated AS (

    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY trip_id ORDER BY (updated_at_timestamp) DESC ) AS row_num
    FROM raw_trips

)
SELECT 
    trip_status,
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
FROM deduplicated
WHERE row_num = 1
