WITH orders AS (

    SELECT * FROM {{ ref('int_orders') }}

)

SELECT
  o.store_id,
  DATE_TRUNC(o.order_date, MONTH) AS order_month,
  COUNT(DISTINCT o.order_id) AS total_orders,
  SUM(o.total_items) AS total_items_sold,
  ROUND(SUM(o.total_order_amount), 2) AS total_revenue,
  ROUND(SUM(o.total_order_amount) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS avg_order_value,
  ROUND(AVG(CASE WHEN o.is_shipped = 1 THEN o.fulfillment_days END), 2) AS avg_fulfillment_days,
  ROUND(SUM(o.is_on_time) / NULLIF(SUM(o.is_shipped), 0), 2) AS on_time_delivery_rate
FROM orders o
GROUP BY o.store_id, DATE_TRUNC(o.order_date, MONTH)
