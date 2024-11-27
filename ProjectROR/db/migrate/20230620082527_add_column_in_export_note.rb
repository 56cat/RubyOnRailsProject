class AddColumnInExportNote < ActiveRecord::Migration[6.1]
  def change
    add_column :import_export_histories, :updated_by_id, :integer
    add_column :import_export_histories, :import_id, :integer
    add_column :export_notes, :note, :string
    add_column :export_notes, :inventory_product_id, :integer
    add_column :export_notes, :import_id, :integer
  end
end
