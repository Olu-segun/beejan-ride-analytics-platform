WITH successful_payments AS (
    SELECT
        trip_id,
        amount,
        payment_status
    FROM {{ ref('stg_payments') }}
    WHERE payment_status = 'success'
),
completed_trips AS (
    SELECT
        trip_id,
        actual_fare,
        is_corporate,
        city_id
    FROM {{ ref('stg_trips') }}
    WHERE status = 'completed'
)

SELECT
    t.trip_id,
    t.actual_fare,
    p.amount AS amount_collected,
     p.amount - t.actual_fare AS payment_difference,
    t.is_corporate,
    t.city_id,
    p.amount AS net_revenue

FROM completed_trips t
INNER JOIN successful_payments p ON t.trip_id = p.trip_id
