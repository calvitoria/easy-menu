class MenuItem < ApplicationRecord
  belongs_to :menu
  validates :name, presence: true
  validates :menu_id, presence: true
end
