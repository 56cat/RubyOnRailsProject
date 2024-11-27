class ChangeTypeColumnPromotion < ActiveRecord::Migration[6.1]
  def change
    remove_column :promotions, :brand_id
    add_column :promotions, :brand_apply, :jsonb
    # add_column :users, :is_active, :boolean, :default => false
    add_column :deliveries, :brand_id, :integer
  end
end
