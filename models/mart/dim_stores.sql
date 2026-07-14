WITH stores AS (

    SELECT * FROM {{ ref('stg_stores') }}

)

SELECT
  store_id,
  store_name,
  phone,
  email,
  street,
  city,
  state,
  zip_code
FROM stores
