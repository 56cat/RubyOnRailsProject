class AddColumnDiscountInBill < ActiveRecord::Migration[6.1]
  def change
    add_column :bills, :discount, :float
    rename_column :bills, :payment_status, :payment_method
    remove_column :bills, :status

  end
end
