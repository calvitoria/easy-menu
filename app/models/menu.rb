class Menu < ApplicationRecord
  include JsonArraySerializable

  belongs_to :restaurant
  has_many :menu_item_menus, dependent: :destroy
  has_many :menu_items, through: :menu_item_menus

  validates :name, presence: true
  validates :restaurant_id, presence: true

  json_array_field :categories

  def add_menu_item(menu_item)
    if menu_items.exists?(menu_item.id)
      errors.add(:base, "Menu item already exists in menu")
      return false
    end

    menu_items << menu_item
    true
  end

  def remove_menu_item(menu_item)
    if menu_items.include?(menu_item)
      menu_items.delete(menu_item)
      true
    else
      errors.add(:base, "Could not remove menu item from menu")
      false
    end
  end

  def contains?(menu_item)
    menu_items.exists?(menu_item.id)
  end

  def self.with_associations
    includes(:menu_items, :restaurant)
  end
end
