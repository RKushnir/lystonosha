FactoryGirl.define do
  factory :user do
    sequence(:name) {|n| "User #{n}" }
  end
end
