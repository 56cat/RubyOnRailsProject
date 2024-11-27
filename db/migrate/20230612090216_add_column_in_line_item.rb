class AddColumnInLineItem < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :cart_id, :integer
  end
end
