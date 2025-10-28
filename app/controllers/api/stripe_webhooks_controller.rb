class Api::StripeWebhooksController < ActionController::API
  # Stripe Webhook endpoint: verify signature and dispatch by event type
  def create
    payload = request.body.read
    signature = request.env["HTTP_STRIPE_SIGNATURE"]
    secret = ENV["STRIPE_WEBHOOK_SECRET"]

    unless secret.present?
      Rails.logger.warn("Stripe webhook secret is not set")
      return head :bad_request
    end

    begin
      event = Stripe::Webhook.construct_event(payload, signature, secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.warn("Stripe webhook error: #{e.message}")
      return head :bad_request
    end

    case event.type
    when "account.updated"
      account = event.data.object
      account_id = account["id"]
      onboarded = account["charges_enabled"] || account["details_submitted"]
      if (shop = Shop.find_by(stripe_connect_account_id: account_id))
        # update_columnsでコールバックなし・高速反映
        shop.update_columns(stripe_onboarded: onboarded)
      else
        Rails.logger.warn(
          "[StripeWebhook] Shop not found for account_id=#{account_id}"
        )
      end

    when "checkout.session.completed"
      # TODO: 必要に応じて注文確定処理を実装
    when "payment_intent.succeeded"
      # TODO: 必要に応じて入金確定処理を実装
    end

    head :ok
  end
end
