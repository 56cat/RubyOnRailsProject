class CreateExportNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :export_notes do |t|
      t.integer :quantity
      t.float :price
      t.integer :brand_export
      t.integer :brand_import
      t.integer :status
      t.integer :exporter_id
      t.integer :receiver_id
      t.timestamps
    end
  end
end
