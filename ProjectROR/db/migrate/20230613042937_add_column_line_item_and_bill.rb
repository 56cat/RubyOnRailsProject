class AddColumnLineItemAndBill < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :discount, :float
    add_column :line_items, :promotion_id, :integer
    remove_column :line_items, :cart_id

    add_column :bills, :promotion_id, :integer
    add_column :bills, :total, :float
    remove_column :bills, :cart_id

    add_column :promotions, :kind, :integer
  end
end
