class Api::ShopsController < ActionController::API
  include ResponseSerializers
  
  def index
    shops = Shop.all
    render json: { shops: shops.map { |shop| shop_json(shop) } }, status: :ok
  end

  def show
    shop = Shop.find(params[:id])
    render json: { shop: shop_json(shop) }, status: :ok
  end
end
