class AddColumnAndRemoveInExportNote < ActiveRecord::Migration[6.1]
  def change
    add_column :export_notes, :kind, :integer
    remove_column :import_export_histories, :quantity_available
  end
end
