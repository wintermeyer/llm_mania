FactoryBot.define do
  factory :user_role_association, class: "UserRole" do
    association :user
    association :role
  end
end 