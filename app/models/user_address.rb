class UserAddress < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { maximum: 100 }
  validates :postal_code, presence: true, format: { with: /\A\d{3}-?\d{4}\z/ }
  validates :prefecture, presence: true, length: { maximum: 100 }
  validates :city, presence: true
  validates :address1, presence: true
  validates :address2, length: { maximum: 100 }, allow_blank: true
  validates :country, presence: true, length: { maximum: 100 }
  validates :phone, format: { with: /\A\d{10,11}\z/ }, allow_blank: true
end
