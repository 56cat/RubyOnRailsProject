class AddColumnInUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :send_mail_created_at, :datetime
  end
end
