WITH payment_summary AS (

    SELECT
        trip_id,

        COUNT(*) AS payment_attempt_count,

        SUM(CASE WHEN payment_status = 'failed' THEN 1 ELSE 0 END) AS failed_attempts,

        SUM(CASE WHEN payment_status = 'success' THEN 1 ELSE 0 END) AS successful_attempts

    FROM {{ ref('stg_payments') }}
    GROUP BY trip_id
)

SELECT
    t.trip_id,

    CASE
        WHEN t.surge_multiplier > 10 THEN TRUE
        ELSE FALSE
    END AS extreme_surge_flag,

    CASE
        WHEN t.status = 'completed'
             AND p.failed_attempts > 0
             AND p.successful_attempts = 0
        THEN TRUE
        ELSE FALSE
    END AS failed_payment_completed_trip_flag,

    CASE
        WHEN p.successful_attempts > 1 THEN TRUE
        ELSE FALSE
    END AS duplicate_payment_flag,

    p.payment_attempt_count,
    p.failed_attempts,
    p.successful_attempts

FROM {{ ref('stg_trips') }} t

LEFT JOIN payment_summary p
    ON t.trip_id = p.trip_id
