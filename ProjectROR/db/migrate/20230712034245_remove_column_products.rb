class RemoveColumnProducts < ActiveRecord::Migration[6.1]
  def change
    remove_column :products, :price
    remove_column :products, :quantity
  end
end
