With raw_drivers_status_events AS (
    SELECT *,
            ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY event_id DESC )   AS row_num
    FROM {{ source('beejan_ride_dbt', 'driver_status_events_raw') }}
),
renamed_columns AS (
    SELECT
        STATUS as status, 
        EVENT_ID as event_id,
        DRIVER_ID as driver_id,
        EVENT_TIMESTAMP as event_timestamp
    FROM raw_drivers_status_events
)
    SELECT 
            status, 
            event_id,
            driver_id,
            event_timestamp
    FROM renamed_columns

