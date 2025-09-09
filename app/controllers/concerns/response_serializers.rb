module ResponseSerializers
  extend ActiveSupport::Concern

  def user_json(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role
    }
  end

  def shop_json(shop)
    {
      id: shop.id,
      name: shop.name,
      description: shop.description,
      icon_url:   shop.icon.attached?   ? url_for(shop.icon)   : nil,
      header_url: shop.header.attached? ? url_for(shop.header) : nil
    }
  end

  def product_json(product)
    {
      id: product.id,
      name: product.name,
      shop_id: product.shop.id,
      shop_name: product.shop.name,
      description: product.description,
      price_including_tax_cents: product.price_including_tax_cents,
      stock: product.stock_quantity,
      image_url: product.image.attached? ? url_for(product.image) : nil
    }
  end
end
