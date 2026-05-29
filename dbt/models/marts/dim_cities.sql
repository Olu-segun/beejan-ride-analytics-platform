SELECT
    city_id,
    city_name,
    country,
    launch_date
FROM {{ ref('stg_cities') }}
