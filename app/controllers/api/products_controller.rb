class Api::ProductsController < ActionController::API
  include RailsJwtAuth
  include ResponseSerializers
  skip_before_action :authenticate_with_rails_jwt!, only: [ :show, :index ]

  def create
    shop = current_user.shop or return render json: { error: "Shop not found" }, status: :not_found
    pp = create_or_update_product_params
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
    end

    if params[:ids]
      ids = params[:ids].split(",")
      products = Product
        .where(id: ids)
        .includes(shop: { header_attachment: :blob })
        .with_attached_image
      render json: { products: products.map { |product| product_json(product, is_detail: true) } }, status: :ok
    end
  end

  def show
    product = Product.find(params[:id])
    render json: { product: product_json(product, is_detail: true) }, status: :ok
  end

  def update
    product = current_user.shop&.products&.find_by(id: params[:id])
    if product.nil?
      return render json: { error: "商品の編集権限がありません" }, status: :forbidden
    end

    pp = create_or_update_product_params

    price = Integer(pp[:price], exception: false)
    stock = Integer(pp[:stock], exception: false)
    return render json: { errors: [ "price/stock が不正です" ] }, status: :unprocessable_entity if price.nil? || stock.nil?

    ActiveRecord::Base.transaction do
    product.update!(
      name: pp[:name],
      description: pp[:description],
      price_excluding_tax_cents: pp[:price].to_i,
      stock_quantity: pp[:stock].to_i,
    )
    product.image.attach(pp[:image]) if pp[:image]
    end

    render json: { product: product_json(product, is_detail: true) }, status: :ok
  rescue => e
    Rails.logger.error "Error updating product: #{e.message}"
    render json: { errors: [ "商品の更新に失敗しました" ] }, status: :internal_server_error
  end

  def destroy
    product = current_user.shop&.products&.find_by(id: params[:id])
    if product.nil?
      return render json: { error: "商品の削除権限がありません" }, status: :forbidden
    end

    product.destroy!
    render json: { message: "商品を削除しました" }, status: :ok
  rescue => e
    Rails.logger.error "Error destroying product: #{e.message}"
    render json: { errors: [ "商品の削除に失敗しました" ] }, status: :internal_server_error
  end

  private

  def create_or_update_product_params
    params.require(:product).permit(:name, :description, :price, :stock, :image)
  end
end
