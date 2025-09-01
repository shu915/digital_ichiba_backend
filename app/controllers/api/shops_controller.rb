class Api::ShopsController < ActionController::API
  include AppJwtAuth

  def create
        ActiveRecord::Base.transaction do
          current_user.role_shop! unless current_user.role_shop?
          current_user.create_shop! unless current_user.shop
        end

    render json: {
      user: {
      id: current_user.id,
      email: current_user.email,
      name: current_user.name,
      role: current_user.role
      }

    }, status: :ok
  end

  def show
    shop = Shop.find(params[:id])
    render json: shop_json(shop), status: :ok
  end

  def update
    shop = current_user.shop
    unless shop
      return render json: { error: "Shop not found" }, status: :not_found
    end
    ActiveRecord::Base.transaction do
    permitted = shop_params
    shop.update!(permitted.slice(:name, :description))

      shop.icon.attach(permitted[:icon])     if permitted[:icon].present?
      shop.header.attach(permitted[:header]) if permitted[:header].present?
    end

    render json: {
      user:  {
        id: current_user.id,
        email: current_user.email,
        name: current_user.name,
        role: current_user.role
      },
      shop: shop_json(shop)
    }, status: :ok
  end

  private

  def shop_params
    params.require(:shop).permit(:name, :description, :icon, :header)
  end

  def shop_json(shop)
    {
      shop: {
        id: shop.id,
        name: shop.name,
        description: shop.description,
        icon_url:   shop.icon.attached?   ? url_for(shop.icon)   : nil,
        header_url: shop.header.attached? ? url_for(shop.header) : nil
      }
    }
  end
end
