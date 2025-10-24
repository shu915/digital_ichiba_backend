class Api::StripeAccountsController < ActionController::API
  include RailsJwtAuth

  def create
    shop = current_user.shop
    return render json: { error: "Shop not found" }, status: :not_found unless shop

    begin
      base_url = ENV["NEXT_URL"]
      return render json: { error: "NEXT_URL is not set" }, status: :unprocessable_entity unless base_url.present?

      account_id = shop.stripe_connect_account_id
      unless account_id.present?
        account = Stripe::Account.create({
          type: "express",
          country: "JP",
          capabilities: {
            card_payments: { requested: true },
            transfers: { requested: true }
          }
        })
        shop.update!(stripe_connect_account_id: account.id)
        account_id = account.id
      end

      account = Stripe::Account.retrieve(account_id)

      if account.charges_enabled
        return render json: { code: "STRIPE_ALREADY_CONNECTED", message: "Stripe連携済みです" }, status: :conflict
      end

      account_link = Stripe::AccountLink.create({
        account: account_id,
        refresh_url: "#{base_url}/dashboard/shop",
        return_url: "#{base_url}/dashboard/shop",
        type: "account_onboarding"
      })
      render json: { onboarding_url: account_link.url }, status: :ok
    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe error: #{e.message}")
      render json: { error: "Stripe連携エラー: #{e.message}" }, status: :unprocessable_entity
    end
  end
end
