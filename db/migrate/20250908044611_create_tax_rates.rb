class CreateTaxRates < ActiveRecord::Migration[8.0]
  def change
    create_table :tax_rates do |t|
      t.string  :name, null: false, limit: 100
      t.decimal :rate, null: false, precision: 5, scale: 4
      t.datetime :effective_from, null: false
      t.datetime :effective_to

      t.timestamps
    end
  end
end
