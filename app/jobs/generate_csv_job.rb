class GenerateCsvJob < ApplicationJob
  queue_as :default
  require 'csv'

  def perform(objects, headers)
    data = CSV.generate(headers: true) do |csv|
      csv << headers
      objects.find_each do |user|
        csv << headers.map{ |attr| user.send(attr) }
      end
    end
    data
  end

end
