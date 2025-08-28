class Api::ShopsController < ActionController::API
  include AppJwtAuth

  def create
        ActiveRecord::Base.transaction do
          current_user.role_shop! unless current_user.role_shop?
          current_user.create_shop! unless current_user.shop
        end

    render json: {
      id: current_user.id,
      email: current_user.email,
      name: current_user.name,
      role: current_user.role,
      shop_id: current_user.shop.id,
      shop_name: current_user.shop.name
    }, status: :ok
  end
end
