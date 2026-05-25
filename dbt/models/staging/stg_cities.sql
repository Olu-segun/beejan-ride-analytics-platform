{{
    config(
        materialized='table'
    )
}}

WITH raw_cities AS (

    SELECT 
        CITY_ID AS city_id,
        COUNTRY AS country,
        CITY_NAME AS city_name,
        LAUNCH_DATE AS launch_date,
    FROM {{ source('beejan_ride_dbt', 'cities_raw') }}

),
deduplicated AS (

    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY city_id ORDER BY launch_date DESC) AS row_num
    FROM raw_cities

)
SELECT
    city_id,
    country,
    city_name,
    launch_date
FROM deduplicated
WHERE row_num = 1
