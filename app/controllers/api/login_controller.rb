class Api::LoginController < ActionController::API
  include AppJwtAuth

  def create
    render json: {
      user: {
        id:    current_user.id,
        email: current_user.email,
        name:  current_user.name,
        role:  current_user.role
      }
    }
  end
end
