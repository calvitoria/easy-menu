FactoryBot.define do
  factory :restaurant do
    sequence(:name) { |n| "Restaurant #{n}" }
    sequence(:email) { |n| "restaurant_#{n}@example.com" }
    description { "Description for #{name}" }
    address { "#{rand(100..999)} #{[ 'Main St', 'Oak Ave', 'Pine Rd' ].sample}, City" }
  end
end
