class CsvQueueJob < ApplicationJob
  require "csv"
  queue_as :default

  def perform(date, csv)
    begin
      start_time = date[:start_time]
      end_time = date[:end_time]
      products = Product.where(created_at: start_time..end_time)
      attributes = %w{id name}
      csv_data = CSV.generate("\uFEFF") do |csv|
        csv << attributes
        products.each do |product|
          csv << attributes.map{ |attr| product.send(attr) }
        end
      end
      csv.update(status: 1)
      file_name = csv.file_name
      dir_path = Rails.root.join("public", 'csv_exports')
      Dir.mkdir(dir_path) unless File.directory?(dir_path)
      file_path = File.join(dir_path, file_name)
      File.open(file_path, "w") do |f|
        f.write(csv_data)
      end
    rescue
      csv.update(status: 2)
    end

  end
end
