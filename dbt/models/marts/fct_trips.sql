{{
  config(
    materialized = 'incremental',
    unique_key = 'trip_id',
    on_schema_change = 'fail'
  )
}}

SELECT
    t.trip_id,
    t.city_id,
    t.rider_id,
    t.driver_id,
    t.vehicle_id,
    t.pickup_at_timestamp,
    t.dropoff_at_timestamp,
    t.requested_at_timestamp,
    t.updated_at_timestamp,
    t.estimated_fare,
    t.actual_fare,
    t.payment_method,
    t.surge_multiplier,
    t.is_corporate,
    t.trip_status,
    td.duration_minutes,
    nr.net_revenue,
    tf.failed_payment_completed_trip_flag,
    tf.duplicate_payment_flag,
    tf.extreme_surge_flag
FROM {{ ref('stg_trips') }} t
LEFT JOIN {{ ref('int_trips_duration_minutes') }} td
    ON t.trip_id = td.trip_id

LEFT JOIN {{ ref('int_net_revenue') }} nr
    ON t.trip_id = nr.trip_id

LEFT JOIN {{ ref('int_trip_fraud_signals') }} tf
    ON t.trip_id = tf.trip_id

{% if is_incremental() %}

AND t.updated_at_timestamp > (
    SELECT COALESCE(MAX(updated_at_timestamp), '1900-01-01')
    FROM {{ this }}
)

{% endif %}
