class AllowNullProductIdOnOrderItems < ActiveRecord::Migration[8.0]
  def change
    # 注文履歴（order_items）は残しつつ、商品（products）を削除できるようにする
    # - product_id をNULL許容
    # - product削除時は product_id をNULLにする（履歴は title_snapshot 等で表示）
    remove_foreign_key :order_items, :products
    change_column_null :order_items, :product_id, true
    add_foreign_key :order_items, :products, on_delete: :nullify
  end
end


