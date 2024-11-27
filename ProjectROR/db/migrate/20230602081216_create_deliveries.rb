class CreateDeliveries < ActiveRecord::Migration[6.1]
  def change
    create_table :deliveries do |t|
      t.integer :bill_id
      t.string :code
      t.string :address
      t.string :phone
      t.text :note
      t.float :amount
      t.integer :status
      t.timestamps
    end
  end
end
