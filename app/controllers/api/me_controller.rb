class Api::MeController < ActionController::API
  include AppJwtAuth   # ← さっきの concern を利用

  def show
    render json: {
      id:    current_user.id,
      email: current_user.email
    }
  end
end
