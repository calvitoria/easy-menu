FactoryBot.define do
  factory :menu do
    sequence(:name) { |n| "Menu #{n}" }
    description { "Description for Menu #{name}" }
    active { true }
    categories { [ "Breakfast", "Lunch", "Dinner" ].sample(rand(1..2)) }
  end
end
