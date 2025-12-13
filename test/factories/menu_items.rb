FactoryBot.define do
  factory :menu_item do
    sequence(:name) { |n| "Item #{n}" }
    price { rand(5.0..20.0).round(2) }
    vegan { [ true, false ].sample }
    vegetarian { [ true, false ].sample }
    categories { [ "Appetizer", "Main Course", "Dessert" ].sample(rand(1..2)) }
    description { "A delicious #{name.downcase} made with fresh ingredients." }
    spicy { [ true, false ].sample }
    association :menu
  end
end
