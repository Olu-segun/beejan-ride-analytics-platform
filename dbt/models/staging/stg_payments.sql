WITH raw_payments AS (
    SELECT * 
    FROM {{ source('beejan_ride_dbt', 'payments_raw') }}
)
SELECT
        fee,
        amount,
        trip_id,
        currency,
        created_at,
        payment_id,
        payment_status,
        payment_provider
FROM raw_payments
