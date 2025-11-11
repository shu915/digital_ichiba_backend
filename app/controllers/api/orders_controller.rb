class Api::OrdersController < ActionController::API
  include RailsJwtAuth
  include ActionView::Helpers::NumberHelper

  def index
    user = current_user
    return render json: { error: "Unauthorized" }, status: :unauthorized unless user

    page = params[:page].to_i
    page = 1 if page < 1
    per_page = 12

    scope = Order.includes(:shop).where(user_id: user.id)
    total_items = scope.count
    orders = scope.order(created_at: :desc).offset((page - 1) * per_page).limit(per_page)

    render json: {
      orders: orders.map { |o|
        {
          id: o.id,
          placed_at: o.placed_at || o.created_at,
          status: o.status,
          total_cents: o.total_cents,
          subtotal_cents: o.subtotal_cents,
          tax_cents: o.tax_cents,
          shipping_cents: o.shipping_cents,
          shop: { id: o.shop_id, name: o.shop&.name }
        }
      },
      total_items: total_items
    }, status: :ok
  end

  def show
    user = current_user
    return render json: { error: "Unauthorized" }, status: :unauthorized unless user

    order = Order.includes(:order_address, order_items: :product).find_by(id: params[:id], user_id: user.id)
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
