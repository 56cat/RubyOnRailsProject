class AddColumnInBill < ActiveRecord::Migration[6.1]
  def change
    add_column :bills, :payment_status, :integer
    add_column :bills, :cart_id, :integer
    change_column_default :bills, :status, 0
  end
end
