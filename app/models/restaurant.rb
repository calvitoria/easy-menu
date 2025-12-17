class Restaurant < ApplicationRecord
  has_many :menus, dependent: :destroy
  has_many :menu_items, through: :menus

  validates :email,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            allow_blank: true
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
