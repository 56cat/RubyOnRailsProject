class AddUserIdInBill < ActiveRecord::Migration[6.1]
  def change
    add_column :bills, :user_id, :integer
  end
end
