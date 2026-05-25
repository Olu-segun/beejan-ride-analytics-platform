{{
  config(
    materialized='incremental',
    unique_key='event_id',
    on_schema_change='fail'
  )
}}
WITH raw_drivers_status_events AS (

    SELECT
        STATUS AS status,
        EVENT_ID AS event_id,
        DRIVER_ID AS driver_id,
        EVENT_TIMESTAMP AS event_timestamp
    FROM {{ source('beejan_ride_dbt', 'driver_status_events_raw') }}

    {% if is_incremental() %}
    WHERE EVENT_TIMESTAMP >
    (
        SELECT COALESCE(MAX(event_timestamp), '1900-01-01')
        FROM {{ this }}
    )
    {% endif %}

),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY event_timestamp DESC) AS row_num
    FROM raw_drivers_status_events

)

SELECT
    status,
    event_id,
    driver_id,
    event_timestamp
FROM deduplicated
WHERE row_num = 1
