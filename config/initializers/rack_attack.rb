# frozen_string_literal: true

# 本番のみ適用。最小構成: IPごとのリクエスト数を制限して荒いBotを弾く
return unless Rails.env.production?

class Rack::Attack
  # 同一IPから1分あたり100リクエストまで許可（超過で429）
  throttle("req/ip", limit: 100, period: 60) { |req| req.ip }
end
