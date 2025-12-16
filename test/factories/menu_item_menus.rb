FactoryBot.define do
  factory :menu_item_menu do
    association :menu
    association :menu_item
  end
end
