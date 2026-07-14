WITH categories AS (

    SELECT * FROM {{ ref('stg_categories') }}

)

SELECT
  category_id,
  category_name
FROM categories
