WITH stocks AS (

    SELECT * FROM {{ ref('stg_stocks') }}

),

orders AS (

    SELECT * FROM {{ ref('stg_orders') }}

),

order_items AS (

    SELECT * FROM {{ ref('stg_order_items') }}

),

products AS (

    SELECT * FROM {{ ref('stg_products') }}

),

-- the dataset is historical, so "recent" is anchored on the last available
-- order date rather than the real current date
window_bounds AS (

    SELECT MAX(order_date) AS max_order_date FROM orders

),

recent_order_items AS (

    SELECT
      orders.store_id,
      order_items.product_id,
      order_items.quantity
    FROM order_items
    INNER JOIN orders
      ON order_items.order_id = orders.order_id
    CROSS JOIN window_bounds
    WHERE orders.order_date >= DATE_SUB(window_bounds.max_order_date, INTERVAL 365 DAY)

),

demand_by_store_product AS (

    SELECT
      store_id,
      product_id,
      SUM(quantity) AS total_quantity_ordered_ttm
    FROM recent_order_items
    GROUP BY store_id, product_id

),

stock_vs_demand AS (

    SELECT
      s.stock_id,
      s.store_id,
      s.product_id,
      s.quantity AS stock_quantity,
      COALESCE(d.total_quantity_ordered_ttm, 0) AS total_quantity_ordered_ttm,
      ROUND(COALESCE(d.total_quantity_ordered_ttm, 0) / 12, 2) AS avg_monthly_demand,
      CASE
        WHEN COALESCE(d.total_quantity_ordered_ttm, 0) = 0 THEN NULL
        ELSE ROUND(s.quantity / (d.total_quantity_ordered_ttm / 12), 2)
      END AS months_of_stock_remaining
    FROM stocks s 
    LEFT JOIN demand_by_store_product d
      ON s.store_id = d.store_id
      AND s.product_id = d.product_id

)

SELECT
  vs.stock_id,
  vs.store_id,
  vs.product_id,
  p.category_id,
  p.brand_id,
  vs.stock_quantity,
  vs.total_quantity_ordered_ttm,
  vs.avg_monthly_demand,
  vs.months_of_stock_remaining,
  CASE
    WHEN vs.stock_quantity = 0 THEN 'out_of_stock'
    WHEN vs.months_of_stock_remaining <= 6 THEN 'understock'
    WHEN vs.stock_quantity < 5 THEN 'stock_balanced'
    WHEN vs.months_of_stock_remaining >= 24 OR vs.months_of_stock_remaining IS NULL AND vs.stock_quantity >= 5 THEN 'overstock'
    ELSE 'stock_balanced'
  END AS stock_status
FROM stock_vs_demand vs
LEFT JOIN products p
  ON vs.product_id = p.product_id
