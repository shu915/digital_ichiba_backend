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
      session_obj = event.data.object
      session_id = session_obj["id"]
      begin
        session = Stripe::Checkout::Session.retrieve(
          {
            id: session_id,
            expand: [ "line_items.data.price.product" ]
          }
        )
      rescue => e
        Rails.logger.error("[StripeWebhook] Failed to retrieve session #{session_id}: #{e.message}")
        return head :ok
      end

      metadata = session.metadata || {}
      user = User.find_by(id: metadata["user_id"]) || User.find_by(email: session.customer_details&.email)

      line_items = session.line_items&.data || []
      product_ids = line_items.map { |li| li.price&.product&.metadata&.[]("product_id")&.to_i }.compact
      products_by_id = Product.where(id: product_ids).index_by(&:id)
      shop_id_from_products = products_by_id.values.first&.shop_id
      shop = Shop.find_by(id: (metadata["shop_id"] || shop_id_from_products))

      if user.nil? || shop.nil? || products_by_id.empty?
        Rails.logger.warn("[StripeWebhook] Missing user/shop/products for session #{session_id}")
        return head :ok
      end

      # Stripe計算値を優先利用（Checkout Sessionのサマリ）
      subtotal_cents = session["amount_subtotal"].to_i
      shipping_cents = session["total_details"]&.[]("amount_shipping").to_i
      tax_cents = session["total_details"]&.[]("amount_tax").to_i
      total_cents = session["amount_total"].to_i
      # フォールバック（送料が未設定の場合はENV、なければ500）
      if shipping_cents <= 0
        env_shipping = ENV["SHIPPING_CENTS"].to_i
        shipping_cents = env_shipping.positive? ? env_shipping : 500
        # 総額が未設定なら再計算
        total_cents = subtotal_cents + tax_cents + shipping_cents if total_cents <= 0
      end

      begin
        ActiveRecord::Base.transaction do
          order = Order.create!(
            user_id: user.id,
            shop_id: shop.id,
            status: 10, # paid
            subtotal_cents: subtotal_cents,
            tax_cents: tax_cents,
            shipping_cents: shipping_cents,
            total_cents: total_cents,
            placed_at: Time.current
          )

          shipping = session["shipping_details"] || session_obj["shipping_details"]
          if shipping && shipping["address"]
            addr = shipping["address"]
            OrderAddress.create!(
              order_id: order.id,
              full_name: shipping["name"].to_s.presence || user.name.to_s,
              phone: shipping["phone"].to_s.gsub(/-/, ""),
              postal_code: addr["postal_code"].to_s,
              country_code: addr["country"].to_s.presence || "JP",
              state: addr["state"].to_s,
              city: addr["city"].to_s,
              line1: addr["line1"].to_s,
              line2: addr["line2"].to_s
            )
          end

          line_items.each do |li|
            pid = li.price&.product&.metadata&.[]("product_id")&.to_i
            qty = li.quantity.to_i
            product = products_by_id[pid]
            next unless product && qty > 0

            OrderItem.create!(
              order_id: order.id,
              product_id: product.id,
              title_snapshot: product.name,
              unit_price_cents_snapshot: product.price_excluding_tax_cents,
              quantity: qty
            )
          end
        end
      rescue => e
        Rails.logger.error("[StripeWebhook] create order failed: #{e.class} #{e.message}")
        return head :ok
      end
    when "payment_intent.succeeded"
      # TODO: 必要に応じて入金確定処理を実装
    end

    head :ok
  end
end
