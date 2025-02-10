json.extract! plan, :id, :name, :slug, :price, :is_active, :created_at, :updated_at
json.url plan_url(plan, format: :json)
