FactoryBot.define do
factory :menu_item do
    sequence(:name) { |n| "Item #{n}" }
    price { rand(5.0..20.0).round(2) }
    association :menu
  end
end
