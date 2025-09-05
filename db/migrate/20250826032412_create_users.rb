class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    enable_extension "citext" unless extension_enabled?("citext")

    create_table :users do |t|
      t.citext  :email, null: false
      t.string  :name,  limit: 20
      t.integer :role,  null: false, default: 0         # 0:customer,5:shop,10:admin
      t.text    :stripe_customer_id

      t.timestamps
    end

    # 一意制約
    add_index :users, :email, unique: true
    add_index :users, :stripe_customer_id, unique: true

    # citext は limit が使えないので、長さは CHECK 制約で
    add_check_constraint :users,
      "char_length(email) <= 100",
      name: "users_email_maxlen_100"

    # 役割を整数のみに（任意：範囲チェック）
    add_check_constraint :users,
      "role in (0,5,10)",
      name: "users_role_enum_values"
  end
end
