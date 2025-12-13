class MenuItem < ApplicationRecord
  belongs_to :menu
  validates :name, presence: true
  validates :menu_id, presence: true

  def categories
    JSON.parse(super || "[]")
  end

  def categories=(value)
    super(value.to_json)
  end
end
