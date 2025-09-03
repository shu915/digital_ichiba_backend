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
    }
  end
end
