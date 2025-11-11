# app/models/user.rb
class User < ApplicationRecord
  has_many :user_identities, dependent: :destroy
  has_one :shop, dependent: :destroy
  has_many :user_addresses, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error

  enum :role, { customer: 0, shop: 5, admin: 10 }, prefix: true

  validates :email, presence: true, length: { maximum: 100 }
  validates :name,  length: { maximum: 20 }
end
