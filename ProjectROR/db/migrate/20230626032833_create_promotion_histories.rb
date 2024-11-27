class CreatePromotionHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :promotion_histories do |t|
      t.integer :promotion_id
      t.integer :user_id
      t.integer :bill_id
      t.timestamps
    end
  end
end
