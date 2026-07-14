WITH stock_vs_demand AS (

    SELECT * FROM {{ ref('int_stock_vs_demand') }}

)

SELECT
  svd.store_id,
  svd.category_id,
  COUNT(*) AS total_products_tracked,
  COUNTIF(svd.stock_status = 'out_of_stock') AS out_of_stock_products,
  COUNTIF(svd.stock_status = 'understock') AS understock_products,
  COUNTIF(svd.stock_status = 'stock_balanced') AS balanced_products,
  COUNTIF(svd.stock_status = 'overstock') AS overstock_products,
  ROUND(COUNTIF(svd.stock_status = 'out_of_stock') / COUNT(*), 2) AS pct_out_of_stock,
  ROUND(COUNTIF(svd.stock_status = 'understock') / COUNT(*), 2) AS pct_understock,
  ROUND(COUNTIF(svd.stock_status = 'overstock') / COUNT(*), 2) AS pct_overstock
FROM stock_vs_demand svd
GROUP BY svd.store_id, svd.category_id
