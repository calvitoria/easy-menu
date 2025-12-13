class Menu < ApplicationRecord
  has_many :menu_items, dependent: :destroy
  validates :name, presence: true

  def categories
    JSON.parse(super || "[]")
  end

  def categories=(value)
    super(value.to_json)
  end
end
