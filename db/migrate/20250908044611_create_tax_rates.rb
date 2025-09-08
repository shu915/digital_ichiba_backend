class CreateTaxRates < ActiveRecord::Migration[8.0]
  def change
    create_table :tax_rates do |t|
      t.string  :name, null: false, limit: 100
      t.decimal :rate, null: false, precision: 5, scale: 4
      t.datetime :effective_from, null: false
      t.datetime :effective_to

      t.timestamps
    end

    add_check_constraint :tax_rates,
      "rate >= 0 AND rate <= 1",
      name: "tax_rates_rate_between_0_1_chk"
    add_check_constraint :tax_rates,
      "(effective_to IS NULL) OR (effective_to > effective_from)",
      name: "tax_rates_effective_range_chk"

    # 検索最適化
    add_index :tax_rates, :effective_from
    add_index :tax_rates, [:effective_from, :effective_to]

    # open-endedレコードは常に1件のみ
    add_index :tax_rates, :effective_to,
      unique: true,
      where: "effective_to IS NULL",
      name: "index_tax_rates_one_open_ended"
  end
end
