class Api::ShopController < ActionController::API
  include AppJwtAuth
  include ResponseSerializers

  def create
    ActiveRecord::Base.transaction do
      current_user.role_shop! unless current_user.role_shop?
      current_user.create_shop! unless current_user.shop
    end

    render json: {
      user: user_json(current_user),
      shop: {
        id: current_user.shop.id,
        name: current_user.shop.name
      }
    }, status: :ok
  end

  def show
    shop = current_user.shop
    render json: { shop: shop_json(shop) }, status: :ok
  end

  def update
    shop = current_user.shop
    unless shop
      return render json: { error: "Shop not found" }, status: :not_found
    end

    ActiveRecord::Base.transaction do
      permitted = shop_params
      shop.update!(permitted.slice(:name, :description))

      shop.icon.attach(permitted[:icon]) if permitted[:icon].present?
      shop.header.attach(permitted[:header]) if permitted[:header].present?
    end

    render json: {
      user: user_json(current_user),
      shop: {
        id: shop.id,
        name: shop.name,
        description: shop.description
      }
    }, status: :ok
  end

  private

  def shop_params
    params.require(:shop).permit(:name, :description, :icon, :header)
  end
end
