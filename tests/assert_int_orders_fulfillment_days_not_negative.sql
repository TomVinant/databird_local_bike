SELECT order_id, order_date, shipped_date, fulfillment_days
FROM {{ ref('int_orders') }}
WHERE fulfillment_days < 0
