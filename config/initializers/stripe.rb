# config/initializers/stripe.rb

# Stripeライブラリを読み込み
require "stripe"

# StripeのAPIキーを設定（ENVから取得）
Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")

# ログ出力（開発時に確認用）
if Rails.env.development?
  Rails.logger.info "✅ Stripe initialized with account: #{Stripe::Account.retrieve.id}"
end
