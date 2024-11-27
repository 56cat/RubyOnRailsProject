class DeliveryJob < ApplicationJob
  queue_as :default

  def perform(action, data = {})
    DeliveryStatusMailer.public_send(action, data).deliver_later
  end
end
