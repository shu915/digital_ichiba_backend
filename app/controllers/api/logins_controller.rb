class Api::LoginsController < ActionController::API
  include AppJwtAuth

  def create
    render json: {
      user: {
        id: current_user.id,
        email: current_user.email,
        name: current_user.name,
        role: current_user.role
      },
      shop: {
        id: current_user.shop.id,
        name: current_user.shop.name,
        description: current_user.shop.description,
        icon_url: current_user.shop.icon.attached? ? url_for(current_user.shop.icon) : nil,
        header_url: current_user.shop.header.attached? ? url_for(current_user.shop.header) : nil
      }
    }
  end
end
