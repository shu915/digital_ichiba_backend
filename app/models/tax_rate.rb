class TaxRate < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :rate, presence: true, numericality: true
  validates :effective_from, presence: true

  scope :current_at, ->(time) do
    where("effective_from <= ? AND (effective_to IS NULL OR effective_to > ?)", time, time)
      .order(effective_from: :desc)
  end

  def self.current_rate(time = Time.current)
    current_at(time).limit(1).pick(:rate)
  end
end
