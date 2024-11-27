class InventoryProductJob < ApplicationJob
  queue_as :default

  require 'csv'

  def perform(action, data)
    begin
      if data[:file].present?
        file = File.open(data[:file])
        message = ImportDataCsvService.new(file, data[:user], data[:brand]).public_send(action)
        # File.delete(file) em muôn xoa file sau khi import xong nhưng đang bị lỗi permission
      else
        message = ['Không tìm thây file']
      end
    rescue => e
      message = [e.message]
    end
    ActionCable.server.broadcast "csv_queue_channel", { message: message }
    DeliveryStatusMailer.send_mail_import_done(message, data[:user]).deliver_later
  end

end
