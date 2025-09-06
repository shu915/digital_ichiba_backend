class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.references :shop, null: false, foreign_key: true
      t.string :name, null: false, limit: 120
      t.text :description # DB制約は下で追加
      t.integer :price_excluding_tax_cents, null: false
      t.integer :stock_quantity, null: false, default: 0
      t.boolean :is_published, null: false, default: false

      t.timestamps
    end

    # DB側の安全網として500文字制約を追加（PostgreSQL: char_length）
    add_check_constraint :products,
      "(description IS NULL) OR (char_length(description) <= 500)",
       name: "products_description_length_chk"
       add_check_constraint :products,
             "price_excluding_tax_cents >= 0",
             name: "products_price_nonneg_chk"
             add_check_constraint :products,
             "stock_quantity >= 0",
             name: "products_stock_nonneg_chk"
  end
end
