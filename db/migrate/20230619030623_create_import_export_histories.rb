class CreateImportExportHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :import_export_histories do |t|
      t.string :owner_type
      t.integer :owner_id
      t.integer :quantity
      t.integer :quantity_available
      t.float :buy_price
      t.string :target_type
      t.string :target_id
      t.integer :action
      t.string :lot_number
      t.datetime :expiry_date
      t.string :note
      t.integer :brand_id
      t.timestamps
    end
  end
end
