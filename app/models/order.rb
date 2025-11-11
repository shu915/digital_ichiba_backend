class Order < ApplicationRecord
  belongs_to :user
  belongs_to :shop

  has_one  :order_address, dependent: :destroy
  has_many :order_items,   dependent: :destroy

  enum :status, { pending: 0, paid: 10, cancelled: 20, refunded: 30 }, prefix: true
end
