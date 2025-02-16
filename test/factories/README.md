# Test Factories

This directory contains factory definitions for our test suite using FactoryBot.

## Usage Example

```ruby
# In your test file
test "creating a user" do
  user = create(:user)
  assert user.valid?
end

# With traits or attributes
test "creating an admin user" do
  admin = create(:user, role: "admin")
  assert admin.admin?
end
```

## Factory Organization

Each model should have its own factory file named after the model in singular form:
- `user.rb` for User model
- `subscription.rb` for Subscription model
- etc.

## Best Practices

1. Keep factories minimal with only required attributes
2. Use traits for common variations
3. Use sequences for unique fields
4. Use associations when necessary
5. Follow the same patterns as defined in `docs/database_architecture.md` 