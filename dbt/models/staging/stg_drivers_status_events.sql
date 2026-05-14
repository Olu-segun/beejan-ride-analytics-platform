With raw_drivers_status_events AS (
    SELECT * 
    FROM {{ source('beejan_ride_dbt', 'driver_status_events_raw') }}
)
SELECT
        status,
        event_id,
        driver_id,
        event_timestamp
FROM raw_drivers_status_events
