# config/initializers/stripe.rb

# Stripeライブラリを読み込み
require "stripe"

# StripeのAPIキーを設定（ENVから取得）
Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
