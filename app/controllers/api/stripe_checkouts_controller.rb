class Api::StripeCheckoutsController < ActionController::API
  include RailsJwtAuth

  def create
    sp = stripe_checkout_params
    cart = sp[:cart]
    return render json: { error: "Cart is required" }, status: :unprocessable_entity unless cart.present?

    base_url = ENV["NEXT_URL"]
    return render json: { error: "NEXT_URL is not set" }, status: :unprocessable_entity unless base_url.present?

    # cart: [{ product_id, quantity }] を想定（シンプル）
    product_ids = cart.map { |i| i[:product_id] }.compact.uniq
    return render json: { error: "No product ids" }, status: :unprocessable_entity if product_ids.empty?

    products_by_id = Product.where(id: product_ids).index_by(&:id)
    missing_ids = product_ids - products_by_id.keys
    return render json: { error: "Invalid product ids: #{missing_ids.join(",")}" }, status: :unprocessable_entity if missing_ids.any?

    # すべて同一ショップの商品に限定（ショップIDは商品から導出）
    shop_ids = products_by_id.values.map(&:shop_id).uniq
    return render json: { error: "Products must belong to the same shop" }, status: :unprocessable_entity unless shop_ids.size == 1
    shop = Shop.find(shop_ids.first)

    # 価格は必ずサーバー側で算出（税込）。通貨はJPY前提。
    line_items = []
    total_cents = 0
    cart.each do |item|
      pid = item[:product_id]
      quantity = item[:quantity].to_i
      next if quantity <= 0
      product = products_by_id[pid]
      return render json: { error: "Product not found" }, status: :unprocessable_entity if product.nil?
      unit_amount = product.price_including_tax_cents
      total_cents += unit_amount * quantity
      line_items << {
        price_data: {
          currency: "jpy",
          unit_amount: unit_amount,
          product_data: {
            name: product.name,
            metadata: { product_id: product.id }
          }
        },
        quantity: quantity
      }
    end
    return render json: { error: "No valid line items" }, status: :unprocessable_entity if line_items.empty?

    # 送料と手数料（任意）
    shipping_cents = ENV["SHIPPING_CENTS"].to_i
    return render json: { error: "SHIPPING_CENTS is not set" }, status: :unprocessable_entity unless shipping_cents.positive?

    fee_percent = (ENV["PLATFORM_FEE_PERCENT"] || "0").to_f
    application_fee_amount = ((total_cents + shipping_cents) * (fee_percent / 100.0)).floor

    session_params = {
      mode: "payment",
      line_items: line_items,
      success_url: "#{base_url}/cart/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url:  "#{base_url}/cart?canceled=1",
      allow_promotion_codes: true,

      billing_address_collection: "required",
      shipping_address_collection: { allowed_countries: [ "JP" ] },
      phone_number_collection: { enabled: true },
      shipping_options: [
        {
          shipping_rate_data: {
            display_name: "通常配送",
            type: "fixed_amount",
            fixed_amount: { amount: shipping_cents, currency: "jpy" }
          }
        }
      ]
    }
    # 注文確定用のメタデータ（Webhookで参照）
    session_params[:metadata] = {
      user_id: current_user.id.to_s,
      shop_id: shop.id.to_s
    }
    # 顧客IDがあれば設定（任意）
    if current_user.respond_to?(:stripe_customer_id) && current_user.stripe_customer_id.present?
      session_params[:customer] = current_user.stripe_customer_id
    end
    # Connect 送金（任意）
    if shop.stripe_connect_account_id.present?
      session_params[:payment_intent_data] = {
        application_fee_amount: application_fee_amount,
        transfer_data: { destination: shop.stripe_connect_account_id }
      }
    end

    checkout = Stripe::Checkout::Session.create(session_params)
    render json: { url: checkout.url }, status: :ok
  end


  private

  def stripe_checkout_params
    if params[:stripe_checkout].present?
      permitted = params.require(:stripe_checkout).permit(cart: [ :product_id, :quantity ])
    else
      permitted = params.permit(cart: [ :product_id, :quantity ])
    end
    { cart: Array(permitted[:cart]).map { |h| h.to_h.symbolize_keys.slice(:product_id, :quantity) } }
  end
end
