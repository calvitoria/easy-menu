class Menu < ApplicationRecord
  include JsonArraySerializable

  belongs_to :restaurant
  has_many :menu_item_menus, dependent: :destroy
  has_many :menu_items, through: :menu_item_menus

  validates :name, presence: true
  validates :restaurant_id, presence: true

  json_array_field :categories
end
