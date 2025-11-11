class Api::ShopController < ActionController::API
  include RailsJwtAuth
  include ResponseSerializers


  def create
    ActiveRecord::Base.transaction do
      current_user.role_shop! unless current_user.role_shop?
      current_user.create_shop! unless current_user.shop
    end

    render json: {
      user: user_json(current_user),
      shop: shop_json(current_user.shop)
    }, status: :ok
  end

  def show
    shop = current_user.shop
    unless shop
      return render json: { error: "Shop not found" }, status: :not_found
    end

    render json: {
      user: user_json(current_user),
      shop: shop_json(shop)
      }, status: :ok
  end

  def update
    shop = current_user.shop
    unless shop
      return render json: { error: "Shop not found" }, status: :not_found
    end

    ActiveRecord::Base.transaction do
      permitted = shop_params
      if shop.update(permitted.slice(:name, :description))
        shop.icon.attach(permitted[:icon])     if permitted[:icon].present?
        shop.header.attach(permitted[:header]) if permitted[:header].present?
      else
        return render json: { errors: shop.errors.full_messages }, status: :unprocessable_entity
      end
    end

    render json: {
      user: user_json(current_user),
      shop: shop_json(shop)

    }, status: :ok
  end

  private

  def shop_params
    params.require(:shop).permit(:name, :description, :icon, :header)
  end
end
