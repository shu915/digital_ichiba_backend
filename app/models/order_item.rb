class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :title_snapshot, presence: true
  validates :unit_price_cents_snapshot, presence: true, 
                                        numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, 
                       numericality: { only_integer: true, greater_than: 0 }
end
