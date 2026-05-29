{% test completed_trip_has_successful_payment(model) %}

WITH completed_trips AS (

    SELECT
        trip_id
    FROM {{ model }}
    WHERE status = 'completed'

),

successful_payments AS (

    SELECT DISTINCT
        trip_id
    FROM {{ ref('stg_payments') }}
    WHERE payment_status = 'success'

)

SELECT
    ct.trip_id
FROM completed_trips ct
LEFT JOIN successful_payments sp
    ON ct.trip_id = sp.trip_id
WHERE sp.trip_id IS NULL 

{% endtest %}
