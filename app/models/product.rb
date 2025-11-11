class Product < ApplicationRecord
  belongs_to :shop
  has_many :order_items, dependent: :nullify
  has_one_attached :image

  validates :name, presence: true, length: { maximum: 120 }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :price_excluding_tax_cents, presence: true,
                                        numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }

  # 税込価格を計算して返す。DBには保存しない仮想属性。
  def price_including_tax_cents(at: Time.current)
    rate = (TaxRate.current_rate(at) || 0).to_f
    (price_excluding_tax_cents * (1.0 + rate)).ceil
  end
end
