class Api::ShopsController < ActionController::API
  include ResponseSerializers

  def index
    # limit指定があり、ページネーション指定がない場合は新着上位の簡易取得
    if params[:limit].present? && params[:page].blank?
      limit = params[:limit].to_i
      limit = 5 if limit <= 0 || limit > 50
      shops = Shop
        .order(created_at: :desc)
        .limit(limit)
        .with_attached_icon
        .with_attached_header
      return render json: { shops: shops.map { |shop| shop_json(shop) } }, status: :ok
    end

    # ページネーション（一覧用）
    per_page = 12
    page = params[:page].to_i
    page = 1 if page < 1
    total_items = Shop.count
    shops = Shop
      .order(created_at: :desc)
      .offset((page - 1) * per_page)
      .limit(per_page)
      .with_attached_icon
      .with_attached_header
    render json: {
      shops: shops.map { |shop| shop_json(shop) },
      total_items: total_items
    }, status: :ok
  end

  def show
    shop = Shop.find(params[:id])
    render json: { shop: shop_json(shop) }, status: :ok
  end
end
