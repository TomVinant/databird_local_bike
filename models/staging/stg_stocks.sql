SELECT
  {{ dbt_utils.generate_surrogate_key(['store_id','product_id']) }} AS stock_id,
  store_id,
  product_id,
  quantity
FROM {{ source('localbike_database', 'stocks') }}