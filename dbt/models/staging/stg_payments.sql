{{
    config(
        materialized='incremental',
        unique_key='payment_id',
        on_schema_change='fail'
    )
}}

WITH raw_payments AS (

    SELECT
        AMOUNT AS amount,
        TRIP_ID AS trip_id,
        CURRENCY AS currency,
        TO_TIMESTAMP(CREATED_AT) AS created_at_timestamp,
        PAYMENT_ID AS payment_id,
        PAYMENT_STATUS AS payment_status,
        PAYMENT_PROVIDER AS payment_provider
    FROM {{ source('beejan_ride_dbt', 'payments_raw') }}

    {% if is_incremental() %}

        WHERE (created_at_timestamp) >= (SELECT COALESCE(MAX(created_at_timestamp),'1900-01-01')
        FROM {{ this }}
        )

    {% endif %}

), 

deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY payment_id ORDER BY TO_TIMESTAMP(created_at_timestamp) DESC ) AS row_num
    FROM raw_payments
)
SELECT
        amount,
        trip_id,
        currency,
        created_at_timestamp,
        payment_id,
        payment_status,
        payment_provider
FROM deduplicated
WHERE row_num = 1
