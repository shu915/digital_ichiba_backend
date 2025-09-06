class Shop < ApplicationRecord
  belongs_to :user
  has_many :products, dependent: :destroy

  has_one_attached :icon
  has_one_attached :header

  validates :name, length: { maximum: 40 }
  validates :description, length: { maximum: 2000 }
end
