SELECT
  staff_id,
  first_name,
  last_name,
  email,
  phone,
  store_id,
  active AS is_active,
  manager_id
FROM {{ source('localbike_database', 'staffs') }}