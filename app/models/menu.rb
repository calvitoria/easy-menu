class Menu < ApplicationRecord
  include JsonArraySerializable

  belongs_to :restaurant
  has_many :menu_items, dependent: :destroy

  validates :name, presence: true
  validates :restaurant_id, presence: true

  json_array_field :categories
end
