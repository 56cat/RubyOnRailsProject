class AddCloumnInLineItem < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :target_type, :string
    add_column :line_items, :target_id, :integer
    remove_column :line_items, :product_id
    remove_column :import_export_histories, :expiry_date
    remove_column :import_export_histories, :lot_number
    remove_column :import_export_histories, :import_id
    remove_column :export_notes, :quantity
    remove_column :export_notes, :price
    remove_column :export_notes, :import_id
    remove_column :export_notes, :inventory_product_id
    rename_column :export_notes, :brand_export, :export_brand_id
    rename_column :export_notes, :brand_import, :import_brand_id

  end
end
