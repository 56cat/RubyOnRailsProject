class CreateBills < ActiveRecord::Migration[6.1]
  def change
    create_table :bills do |t|
      t.string :code
      t.float :amount
      t.integer :status
      t.timestamps
    end
  end
end
