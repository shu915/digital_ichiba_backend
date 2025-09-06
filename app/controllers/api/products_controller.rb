class Api::ProductsController < ActionController::API
  include AppJwtAuth
  include ResponseSerializers
  skip_before_action :authenticate_with_app_jwt!, only: [ :show, :index ]

  def create
    shop = current_user.shop or return render json: { error: "Shop not found" }, status: :not_found
    pp = product_params
    price = Integer(pp[:price], exception: false)
    stock = Integer(pp[:stock], exception: false)
    return render json: { errors: [ "price/stock が不正です" ] }, status: :unprocessable_entity if price.nil? || stock.nil?


    product = shop.products.new(
      name: pp[:name],
      description: pp[:description],
      price_excluding_tax_cents: pp[:price].to_i,
      stock_quantity: pp[:stock].to_i,
    )
    product.image.attach(pp[:image]) if pp[:image]

    if product.save
      render json: { product: product_json(product) }, status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    products = current_user.shop.products
    render json: { products: products.map { |product| product_json(product) } }, status: :ok
  end

  def show
    product = Product.find(params[:id])
    render json: { product: product_json(product) }, status: :ok
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :image)
  end
end
