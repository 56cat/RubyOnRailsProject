class ChangeDefaultValueStatusInDeliveries < ActiveRecord::Migration[6.1]
  def change
    change_column_default :deliveries, :status, 0
  end
end
