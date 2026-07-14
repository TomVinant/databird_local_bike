WITH orders AS (

    SELECT * FROM {{ ref('stg_orders') }}

),

order_items AS (

    SELECT * FROM {{ ref('stg_order_items') }}

),

order_items_agg AS (

    SELECT
      order_id,
      SUM(quantity) AS total_items,
      COUNT(DISTINCT item_id) AS total_distinct_items,
      ROUND(SUM(quantity * list_price * (1 - discount_pct)), 2) AS total_order_amount
    FROM order_items
    GROUP BY order_id

)

SELECT
  orders.order_id,
  orders.customer_id,
  orders.order_status,
  orders.order_date,
  orders.required_date,
  orders.store_id,
  orders.staff_id,
  orders.shipped_date,
  COALESCE(order_items_agg.total_items, 0) AS total_items,
  COALESCE(order_items_agg.total_distinct_items, 0) AS total_distinct_items,
  COALESCE(order_items_agg.total_order_amount, 0) AS total_order_amount,
  DATE_DIFF(orders.shipped_date, orders.order_date, DAY) AS fulfillment_days,
  CASE WHEN orders.shipped_date IS NOT NULL THEN 1 ELSE 0 END AS is_shipped,
  CASE
    WHEN orders.order_status = 3 THEN NULL -- order_status 3 = commande magasin, non applicable
    WHEN orders.shipped_date IS NOT NULL AND orders.shipped_date <= orders.required_date THEN 1
    ELSE 0
  END AS is_on_time
FROM orders
LEFT JOIN order_items_agg
  ON orders.order_id = order_items_agg.order_id