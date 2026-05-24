WITH raw_payments AS (
    SELECT  *,
            ROW_NUMBER() OVER (PARTITION BY payment_id ORDER BY payment_id DESC) AS row_num
    FROM {{ source('beejan_ride_dbt', 'payments_raw') }}
),
renamed_columns AS (
    SELECT
        FEE             as fee,
        AMOUNT          as amount,
        TRIP_ID         as trip_id,
        CURRENCY        as currency,
        TO_TIMESTAMP(CREATED_AT) as created_at,
        PAYMENT_ID      as payment_id,
        PAYMENT_STATUS  as payment_status,
        PAYMENT_PROVIDER as payment_provider
    FROM raw_payments
    WHERE row_num = 1
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
FROM renamed_columns
