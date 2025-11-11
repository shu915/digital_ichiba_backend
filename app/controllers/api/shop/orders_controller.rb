class Api::Shop::OrdersController < ActionController::API
  include RailsJwtAuth

  def index
    shop = current_user&.shop
    return render json: { error: "Unauthorized" }, status: :unauthorized unless shop

    orders = Order.includes(:user).where(shop_id: shop.id).order(created_at: :desc).limit(50)
    render json: {
      orders: orders.map { |o|
        {
          id: o.id,
          placed_at: o.placed_at || o.created_at,
          status: o.status,
          total_cents: o.total_cents,
          customer: { id: o.user_id, email: o.user&.email, name: o.user&.name }
        }
      }
    }, status: :ok
  end

  def show
    shop = current_user&.shop
    return render json: { error: "Unauthorized" }, status: :unauthorized unless shop

    order = Order.includes(:order_address, order_items: :product).find_by(id: params[:id], shop_id: shop.id)
    return render json: { error: "Not found" }, status: :not_found unless order

    render json: {
      order: {
        id: order.id,
        placed_at: order.placed_at || order.created_at,
        status: order.status,
        subtotal_cents: order.subtotal_cents,
        tax_cents: order.tax_cents,
        shipping_cents: order.shipping_cents,
        total_cents: order.total_cents,
        customer: { id: order.user_id, email: order.user&.email, name: order.user&.name },
        address: order.order_address && {
          full_name: order.order_address.full_name,
          phone: order.order_address.phone,
          postal_code: order.order_address.postal_code,
          country_code: order.order_address.country_code,
          state: order.order_address.state,
          city: order.order_address.city,
          line1: order.order_address.line1,
          line2: order.order_address.line2
        },
        items: order.order_items.map { |i|
          {
            product_id: i.product_id,
            title: i.title_snapshot,
            unit_price_cents: i.unit_price_cents_snapshot,
            quantity: i.quantity
          }
        }
      }
    }, status: :ok
  end
end


