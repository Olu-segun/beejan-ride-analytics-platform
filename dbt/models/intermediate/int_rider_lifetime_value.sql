SELECT
    rider_id,
    SUM(actual_fare) AS rider_lifetime_value
FROM {{ ref('stg_trips') }}
WHERE status = 'completed'
GROUP BY rider_id
