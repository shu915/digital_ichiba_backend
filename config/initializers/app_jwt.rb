raw = ENV["APP_JWT_PUBLIC_KEY"]

if raw.present?
  # 文字列 "\n" を本物の改行に置換
  key_text = raw.gsub("\\n", "\n")

  APP_JWT_PUBLIC_KEY = OpenSSL::PKey::RSA.new(key_text)
  APP_JWT_ISS = "digital-ichiba-next"
  APP_JWT_AUD = "digital-ichiba-rails"
else
  Rails.logger.warn("[JWT] APP_JWT_PUBLIC_KEY is not set.")
  APP_JWT_PUBLIC_KEY = nil
end
