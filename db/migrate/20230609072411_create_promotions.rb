class CreatePromotions < ActiveRecord::Migration[6.1]
  def change
    create_table :promotions do |t|
      t.string :name  #tên mã
      t.string :code  #code
      t.integer :percent_discount #phần trăm giảm giá
      t.float :max_amount #số tiền tối đa
      t.jsonb :user_apply  #áp dụng cho ng
      t.jsonb :product_apply #áp dụng cho sản phẩm
      t.integer :max_uses #số lần dùng tối đa
      t.datetime :start #ngày bắt dầu
      t.datetime :end  #ngày kết thúc
      t.timestamps
    end
  end
end
