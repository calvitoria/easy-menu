class Menu < ApplicationRecord
  include JsonArraySerializable

  has_many :menu_items, dependent: :destroy

  validates :name, presence: true

  json_array_field :categories
end
