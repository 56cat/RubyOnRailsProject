class CreateCarts < ActiveRecord::Migration[6.1]
  def change
    create_table :carts do |t|
      t.float :total
      t.float :subtotal
      t.float :discount
      t.integer :promotion_id
      t.boolean :is_active
      t.timestamps
    end
  end
end
