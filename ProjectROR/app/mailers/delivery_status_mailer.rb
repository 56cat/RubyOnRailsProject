class DeliveryStatusMailer < ApplicationMailer

  def send_mail(data)
    @user = data[:user]
    @delivery = data[:delivery]
    @bill = @delivery.bill
    @line_items = @delivery.line_items.where(brand_id: @delivery.brand_id)
    mail from: "kiai.nam.nguyen@gmail.com", to: @user.email, subject: "Thay đổi trạng thái đơn hàng #{@delivery.code}"
  end

  def send_mail_create_delivery(data)
    @delivery   = data[:delivery]
    @brand = Brand.find_by(id: @delivery.brand_id)
    user_mail = User.where(role: 'supplier', brand_id: @delivery.brand_id).pluck(:email)
    mail from: "kiai.nam.nguyen@gmail.com", to: user_mail, subject: "Đơn đặt hàng mới #{@delivery.code}"
  end

  def send_mail_import_done(message, user)
    @message = message
    mail from: "kiai.nam.nguyen@gmail.com", to: user.email, subject: "Hoàn thành nhập file"
  end

end
