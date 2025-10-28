class AddStripeOnboardedToShops < ActiveRecord::Migration[8.0]
  def change
    add_column :shops, :stripe_onboarded, :boolean, null: false, default: false
  end
end
