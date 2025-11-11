class CreateOrderAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :order_addresses do |t|
      t.references :order, null: false, foreign_key: true
      t.string :full_name, null: false
      t.string :phone
      t.string :postal_code, null: false
      t.string :country_code, null: false, default: "JP", limit: 2
      t.string :state, null: false
      t.string :city, null: false
      t.string :line1, null: false
      t.string :line2
      t.timestamps
    end
  end
end
