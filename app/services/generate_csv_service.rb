class GenerateCsvService
  require 'csv'
  attr_reader :objects, :headers
  def initialize(objects, headers)
    @objects = objects
    @headers = headers
  end

  def perform
    # GenerateCsvJob.perform_later(objects, headers)
  end


end