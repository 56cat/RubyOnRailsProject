class CsvQueueChannel < ApplicationCable::Channel
  def subscribed
    stream_from "csv_queue_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
