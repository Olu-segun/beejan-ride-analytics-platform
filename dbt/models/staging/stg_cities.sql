WITH raw_cities AS (
    SELECT  *,
            ROW_NUMBER() OVER (PARTITION BY city_id ORDER BY city_id DESC) AS row_num
    FROM {{ source('beejan_ride_dbt', 'cities_raw') }}
),
renamed_columns AS (
    SELECT
        CITY_ID     as city_id,
        COUNTRY     as country,
        CITY_NAME   as city_name,
        LAUNCH_DATE as launch_date
    FROM raw_cities
    WHERE row_num = 1
)
SELECT
    city_id,
    city_name,
    country,
    launch_date
FROM renamed_columns
