SELECT stock_id, store_id, product_id, months_of_stock_remaining
FROM {{ ref('int_stock_vs_demand') }}
WHERE months_of_stock_remaining < 0
