SELECT
    driver_id,
    COUNT(trip_id) AS driver_lifetime_trips
FROM {{ ref('stg_trips') }}
WHERE status = 'completed'
GROUP BY driver_id
