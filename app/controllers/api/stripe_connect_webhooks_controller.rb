class Api::StripeConnectWebhooksController < ActionController::API
  # Stripe Connect webhook endpoint: verify signature and handle Connect events
  def create
    payload = request.body.read
    signature = request.env["HTTP_STRIPE_SIGNATURE"]
    secret = ENV["STRIPE_CONNECT_WEBHOOK_SECRET"]

    unless secret.present?
      Rails.logger.warn("Stripe connect webhook secret is not set")
      return head :bad_request
    end

    begin
      event = Stripe::Webhook.construct_event(payload, signature, secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.warn("Stripe connect webhook error: #{e.message}")
      return head :bad_request
    end

    case event.type
    when "account.updated"
      account = event.data.object
      account_id = account["id"]
      onboarded = account["charges_enabled"]

      if (shop = Shop.find_by(stripe_connect_account_id: account_id))
        # update_columnsでコールバックなし・高速反映
        shop.update_columns(stripe_onboarded: onboarded)
      else
        Rails.logger.warn("[StripeConnectWebhook] Shop not found for account_id=#{account_id}")
      end
    end

    head :ok
  end
end
