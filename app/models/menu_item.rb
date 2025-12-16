class MenuItem < ApplicationRecord
  include JsonArraySerializable

  has_many :menu_item_menus, dependent: :destroy
  has_many :menus, through: :menu_item_menus

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  json_array_field :categories

  def self.with_associations
    includes(:menus)
  end
end
