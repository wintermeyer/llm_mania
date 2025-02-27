# Create default roles
puts "Creating roles..."
admin_role = Role.find_or_create_by!(name: "admin") do |role|
  role.description = "Administrator role with full access"
  role.active = true
  puts "Created admin role"
end

user_role = Role.find_or_create_by!(name: "user") do |role|
  role.description = "Regular user role with standard access"
  role.active = true
  puts "Created user role"
end

puts "Roles created successfully!"
