class AddColumnInTable < ActiveRecord::Migration[6.1]
  def change
    add_column :brands, :kind, :integer
    add_column :users, :brand_id, :integer
    add_column :line_items, :owner_type, :string
    add_column :line_items, :owner_id, :integer
    add_column :line_items, :brand_id, :integer
    add_column :promotions, :brand_id, :integer
  end
end
