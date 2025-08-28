class CreateShops < ActiveRecord::Migration[8.0]
  def change
    create_table :shops do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string  :name, default: "未設定", null: false, limit: 40
      t.text    :description

      t.timestamps
    end

    # description を 2000文字以内に制限
    add_check_constraint :shops,
      "(description IS NULL) OR (char_length(description) <= 2000)",
      name: "shops_description_length_chk"
  end
end
