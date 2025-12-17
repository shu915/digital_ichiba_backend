# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

TaxRate.find_or_create_by!(name: "日本消費税10%", rate: 0.1, effective_from: Date.new(2019, 10, 01))

# 一般ユーザー（customer）を10人
10.times do |i|
  email = "customer#{i + 1}@example.com"
  User.find_or_create_by!(email:) do |u|
    u.name = "Customer #{i + 1}"
    u.role = :customer
  end
end

10.times do |i|
  user = User.find_or_create_by!(email: "shop#{i + 1}@example.com") do |u|
    u.name = "Shop User #{i + 1}"
    u.role = :shop
  end

  shop = user.shop || Shop.create!(user: user, name: "ショップ#{i + 1}", description: "サンプル#{i + 1}")

  image_path = Rails.root.join("db/seed_files/sample_product.png")

  100.times do |j|
    p = shop.products.create!(
      name: "商品#{j + 1}",
      description: "サンプル商品#{j + 1}",
      price_excluding_tax_cents: (500..5000).step(50).to_a.sample,
      stock_quantity: rand(0..50)
    )
    File.open(image_path) do |file|
      p.image.attach(io: file, filename: "sample_product.png", content_type: "image/png")
    end
  end
end
