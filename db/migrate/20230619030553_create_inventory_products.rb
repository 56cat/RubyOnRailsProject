class CreateInventoryProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :inventory_products do |t|
      t.integer :product_id
      t.float :sell_price
      t.integer :quantity
      t.integer :updated_by_id
      t.integer :brand_id
      t.timestamps
    end
  end
end
