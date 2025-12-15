class MenuItem < ApplicationRecord
  include JsonArraySerializable

  belongs_to :menu

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :menu_id, presence: true

  json_array_field :categories
end
