module RailsJwtAuth
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_rails_jwt!
    attr_reader :current_user
  end

  def authenticate_with_rails_jwt!
    bearer = request.authorization&.split("Bearer ")&.last
    head :unauthorized and return if bearer.blank?

    public_key = OpenSSL::PKey::RSA.new(ENV["APP_JWT_PUBLIC_KEY"].gsub("\\n", "\n"))

    payload, = JWT.decode(
      bearer,
      public_key,
      true,
      { algorithms: [ "RS256" ],
        iss: ENV["APP_JWT_ISS"],
        verify_iss: true,
        aud: ENV["APP_JWT_AUD"],
        verify_aud: true,
        verify_exp: true
      })

    email = payload["email"]
    provider = payload["provider"]
    provider_subject = payload["provider_subject"]
    head :unauthorized and return if email.blank?

    ActiveRecord::Base.transaction do
      @current_user = User.find_or_create_by!(email: email)
      @current_user.user_identities.find_or_create_by!(
        provider: provider,
        provider_subject: provider_subject
      )
    end

  rescue JWT::DecodeError, JWT::ExpiredSignature
    head :unauthorized
  end
end
