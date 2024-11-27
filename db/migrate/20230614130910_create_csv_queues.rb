class CreateCsvQueues < ActiveRecord::Migration[6.1]
  def change
    create_table :csv_queues do |t|
      t.string :file_name
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
