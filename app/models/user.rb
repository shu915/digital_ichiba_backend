# app/models/user.rb
class User < ApplicationRecord
  enum :role, { customer: 0, shop: 5, admin: 10 }, prefix: true

  validates :email, presence: true, length: { maximum: 100 }
  validates :name,  length: { maximum: 20 }
end
