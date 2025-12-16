class MenuItemMenu < ApplicationRecord
  belongs_to :menu
  belongs_to :menu_item

  validates :menu_item_id, uniqueness: { scope: :menu_id }
end
