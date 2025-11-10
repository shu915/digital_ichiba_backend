class CreateUserAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :user_addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :postal_code, null: false
      t.string :prefecture, null: false
      t.string :city, null: false
      t.string :address1, null: false
      t.string :address2
      t.string :country, null: false, default: "JP"
      t.string :phone
      t.timestamps
    end
  end
end
