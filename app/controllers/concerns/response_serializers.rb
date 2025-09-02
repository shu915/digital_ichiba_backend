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
end
