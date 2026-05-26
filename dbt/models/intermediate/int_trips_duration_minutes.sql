{{
  config(
    materialized = 'table',
    )
}}

SELECT
    trip_id,
    DATEDIFF('minute', pickup_at_timestamp, dropoff_at_timestamp) AS duration_minutes
FROM {{ ref('stg_trips') }}
