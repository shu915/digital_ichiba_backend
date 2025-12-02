class UpsertCurrentTaxRate < ActiveRecord::Migration[8.0]
  # 既定（seedで使っていた税率）
  DEFAULT_RATE = 0.10
  DEFAULT_NAME = "日本消費税10%"
  DEFAULT_FROM_DATE = Date.new(2019, 10, 1)

  # モデル定義に依存しない軽量クラス（検証やコールバックを回避）
  class MTaxRate < ApplicationRecord
    self.table_name = "tax_rates"
  end

  def up
    MTaxRate.reset_column_information

    current_open = MTaxRate.where(effective_to: nil).order(effective_from: :desc).first

    # 1) 何も無ければ seed 相当を投入（2019-10-01 適用開始）
    if current_open.nil?
      MTaxRate.create!(
        name: DEFAULT_NAME,
        rate: DEFAULT_RATE,
        effective_from: DEFAULT_FROM_DATE
      )
      return
    end

    # 2) 既に同一税率なら何もしない（冪等）
    return if current_open.rate.to_f == DEFAULT_RATE

    # 3) 税率が異なる場合は、現在の open-ended を閉じて「今から」新税率を適用
    now = Time.current
    MTaxRate.transaction do
      current_open.update!(effective_to: now)
      MTaxRate.create!(
        name: DEFAULT_NAME,
        rate: DEFAULT_RATE,
        effective_from: now
      )
    end
  end

  def down
    MTaxRate.reset_column_information

    # 直近の open-ended を削除し、直前のレコードを再オープン
    current_open = MTaxRate.where(effective_to: nil).order(effective_from: :desc).first
    previous = MTaxRate.where.not(id: current_open&.id).order(effective_from: :desc).first

    MTaxRate.transaction do
      current_open&.destroy!
      previous&.update!(effective_to: nil) if previous
    end
  end
end


