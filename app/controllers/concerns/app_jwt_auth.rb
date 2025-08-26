module AppJwtAuth
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_app_jwt!
    attr_reader :current_user
  end

  def authenticate_with_app_jwt!
    bearer = request.authorization&.split("Bearer ")&.last
    head :unauthorized and return if bearer.blank?

    payload, = JWT.decode(bearer, APP_JWT_PUBLIC_KEY, true,
      { algorithm: "RS256", iss: APP_JWT_ISS, verify_iss: true,
        aud: APP_JWT_AUD, verify_aud: true })
    email = payload["email"] || payload["sub"]
    head :unauthorized and return if email.blank?

    @current_user = User.find_or_create_by!(email: email)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    head :unauthorized
  end
end
