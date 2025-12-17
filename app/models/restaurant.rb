class Restaurant < ApplicationRecord
  has_many :menus, dependent: :destroy
  has_many :menu_items, through: :menus

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
