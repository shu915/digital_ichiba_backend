class AddStripeConnectAccountIdToShops < ActiveRecord::Migration[8.0]
  def change
    add_column :shops, :stripe_connect_account_id, :string
    add_index  :shops, :stripe_connect_account_id, unique: true
  end
end
