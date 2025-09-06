class CreateUserIdentities < ActiveRecord::Migration[8.0]
  def change
    create_table :user_identities do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :provider, null: false, limit: 1   # enum: 0=email, 1=google
      t.text :provider_subject, null: false

      t.timestamps
    end

    # 複合ユニーク制約
    add_index :user_identities, [ :provider, :provider_subject ], unique: true, name: "index_user_identities_on_provider_and_subject"
  end
end
