SELECT
  order_id,
  customer_id,
  order_status,
  order_date,
  required_date,
  store_id,
  staff_id,
  shipped_date
FROM {{ source('localbike_database', 'orders') }}