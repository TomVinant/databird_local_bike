SELECT
  {{ dbt_utils.generate_surrogate_key(['order_id','item_id']) }} AS order_item_id,
  order_id,
  item_id,
  product_id,
  quantity,
  list_price,
  discount AS discount_pct
FROM {{ source('localbike_database', 'order_items') }}