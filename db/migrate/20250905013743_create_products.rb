class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.references :shop, null: false, foreign_key: true
      t.string :name, null: false, limit: 120
      t.text :description, limit: 500
      t.integer :price_excluding_tax_cents, null: false
      t.integer :stock_quantity, null: false, default: 0
      t.boolean :is_published, null: false, default: false

      t.timestamps
    end
  end
end
