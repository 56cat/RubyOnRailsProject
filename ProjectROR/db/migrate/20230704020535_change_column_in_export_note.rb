class ChangeColumnInExportNote < ActiveRecord::Migration[6.1]
  def change
    remove_column :export_notes, :export_brand_id
    remove_column :export_notes, :import_brand_id
    remove_column :export_notes, :exporter_id
    remove_column :export_notes, :receiver_id
    add_column :export_notes, :brand_id, :integer
    add_column :export_notes, :user_id, :integer
  end
end
