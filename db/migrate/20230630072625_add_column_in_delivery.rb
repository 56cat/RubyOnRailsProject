class AddColumnInDelivery < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :user_id, :integer
    add_column :deliveries, :updated_by_id, :integer
    add_column :deliveries, :reason, :string
    add_column :deliveries, :paid, :float
    add_column :deliveries, :unpaid, :float
  end
end
