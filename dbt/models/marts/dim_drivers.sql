{{config
(
    materialized='table',
    schema='marts'
) 
}} 
SELECT 
        s.rating,
        s.city_id,
        s.driver_id,
        s.created_at_timestamp,
        s.updated_at_timestamp,
        s.vehicle_id,
        s.driver_status,
        s.onboarding_date,
        s.dbt_scd_id,
        s.dbt_valid_from,
        s.dbt_valid_to,
        t.driver_lifetime_trips
FROM {{ ref('drivers_snapshot') }} AS s
LEFT JOIN {{ ref('int_driver_lifetime_trips') }} AS t
    ON s.driver_id = t.driver_id
