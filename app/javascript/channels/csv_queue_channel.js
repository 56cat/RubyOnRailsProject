import consumer from "./consumer"

consumer.subscriptions.create("CsvQueueChannel", {
  connected() {
    console.log("consumer connected CsvQueueChannel")
  },

  disconnected() {
    console.log("consumer disconnected CsvQueueChannel")

  },

  received(data) {
    console.log("data CsvQueueChannel", data)
    alert("Đã hoàn thành nhập dữ liệu vui lòng kiểm tra email")
  }
});
