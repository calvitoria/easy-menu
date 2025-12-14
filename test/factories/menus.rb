FactoryBot.define do
  factory :menu do
    sequence(:name) { |n| "Menu #{n}" }
    description { "Description for Menu #{name}" }
    active { true }
    categories { [] }
    association :restaurant
  end
end
