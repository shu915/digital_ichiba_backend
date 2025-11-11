class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :shop, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :subtotal_cents, null: false
      t.integer :tax_cents, null: false
      t.integer :shipping_cents, null: false
      t.integer :total_cents, null: false
      t.datetime :placed_at
      t.timestamps
    end
  end
end
