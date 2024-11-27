class CreateLineItems < ActiveRecord::Migration[6.1]
  def change
    create_table :line_items do |t|
      t.integer :product_id
      t.integer :bill_id
      t.integer :user_id
      t.float :price
      t.integer :quantity
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
