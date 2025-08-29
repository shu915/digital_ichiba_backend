class Shop < ApplicationRecord
  belongs_to :user

  validates :name, length: { maximum: 40 }
  validates :description, length: { maximum: 2000 }
end
