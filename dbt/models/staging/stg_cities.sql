


WITH raw_cities AS (
    SELECT * 
    FROM {{ source('beejan_ride_dbt', 'cities_raw') }}
)
SELECT
    city_id,
    city_name,
    country,
    launch_date
FROM raw_cities


