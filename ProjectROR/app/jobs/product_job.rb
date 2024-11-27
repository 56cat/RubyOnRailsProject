class ProductJob < ApplicationJob
  queue_as :default

  def perform(objects, headers)
  end
end
