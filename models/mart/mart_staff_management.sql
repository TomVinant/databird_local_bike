WITH orders AS (

    SELECT * FROM {{ ref('int_orders') }}

),

stores AS (

    SELECT * FROM {{ ref('stg_stores') }}

),

staff AS (

    SELECT * FROM {{ ref('stg_staffs') }}

),

active_staff_by_store AS (

    SELECT
      store_id,
      COUNT(DISTINCT staff_id) AS active_staff_count
    FROM staff
    WHERE is_active
    GROUP BY store_id

),

-- the dataset is historical, so "recent" is anchored on the last available
-- order date rather than the real current date
window_bounds AS (

    SELECT MAX(order_date) AS max_order_date FROM orders

),

ttm_orders AS (

    SELECT
      o.store_id,
      o.order_id,
      o.total_items,
      o.total_order_amount
    FROM orders o
    CROSS JOIN window_bounds
    WHERE o.order_date >= DATE_SUB(window_bounds.max_order_date, INTERVAL 365 DAY)

),

ttm_performance AS (

    SELECT
      store_id,
      COUNT(DISTINCT order_id) AS total_orders_ttm,
      SUM(total_items) AS total_items_sold_ttm,
      ROUND(SUM(total_order_amount), 2) AS total_revenue_ttm
    FROM ttm_orders
    GROUP BY store_id

)

SELECT
  tp.store_id,
  s.store_name,
  window_bounds.max_order_date AS window_end_date,
  tp.total_orders_ttm,
  tp.total_items_sold_ttm,
  tp.total_revenue_ttm,
  COALESCE(a.active_staff_count, 0) AS active_staff_count,
  ROUND(tp.total_revenue_ttm / NULLIF(a.active_staff_count, 0), 2) AS revenue_per_staff_ttm,
  ROUND(tp.total_items_sold_ttm / NULLIF(a.active_staff_count, 0), 2) AS items_sold_per_staff_ttm
FROM ttm_performance tp
LEFT JOIN stores s
  ON tp.store_id = s.store_id
CROSS JOIN window_bounds
LEFT JOIN active_staff_by_store a
  ON tp.store_id = a.store_id
