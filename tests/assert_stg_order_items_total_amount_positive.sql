SELECT order_id, item_id, product_id, quantity, list_price, discount_pct
FROM {{ ref('stg_order_items') }}
WHERE quantity * list_price * (1 - discount_pct) < 0
