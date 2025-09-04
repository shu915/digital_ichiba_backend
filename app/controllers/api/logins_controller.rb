class Api::LoginsController < ActionController::API
  include AppJwtAuth
  include ResponseSerializers

  def create
    render json: {
      user: user_json(current_user),
      shop: current_user.shop ? shop_json(current_user.shop) : nil
    },
    status: :ok
  end
end
