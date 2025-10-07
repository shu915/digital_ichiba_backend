class Api::ProductsController < ActionController::API
  include RailsJwtAuth
  include ResponseSerializers
  skip_before_action :authenticate_with_app_jwt!, only: [ :show, :index ]

  def create
    shop = current_user.shop or return render json: { error: "Shop not found" }, status: :not_found
    pp = create_product_params
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
      render json: { product: product_json(product, is_detail: true) }, status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    if params[:shop_id]
      scope = Product.all
      scope = scope.where(shop_id: params[:shop_id])

      total_items = scope.count
      page = params[:page].to_i
      page = 1 if page < 1
      products = scope.offset((page - 1) * 12).limit(12).with_attached_image

      render json: {
        products: products.map { |product| product_json(product) },
        total_items: total_items
        }, status: :ok
    else
      products = Product.with_attached_image
      render json: { products: products.map { |product| product_json(product) }, total_items: products.count   }, status: :ok
    end
  end

  def show
    product = Product.find(params[:id])
    render json: { product: product_json(product, is_detail: true) }, status: :ok
  end

  private

  def create_product_params
    params.require(:product).permit(:name, :description, :price, :stock, :image)
  end
end
