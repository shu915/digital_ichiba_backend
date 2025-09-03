class Api::ShopsController < ActionController::API
  include ResponseSerializers

  def create
        ActiveRecord::Base.transaction do
          current_user.role_shop! unless current_user.role_shop?
          current_user.create_shop! unless current_user.shop
        end

    render json: {
      user: user_json(current_user),
      shop: shop_json(current_user.shop)
    }, status: :ok
  end

  def index
    shops = Shop.all
    render json: { shops: shops.map { |shop| shop_json(shop) } }, status: :ok
  end

  def show
    shop = Shop.find(params[:id])
    render json: { shop: shop_json(shop) }, status: :ok
  end
end
