class Product < ApplicationRecord
  belongs_to :shop
  has_one_attached :image

  validates :name, presence: true, length: { maximum: 120 }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :price_excluding_tax_cents, presence: true,
                                        numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }
end
