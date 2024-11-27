class UserMailer < ApplicationMailer

  def send_mail_after_registration(user, password)
    @user = user
    @password = password
    mail from: "kiai.nam.nguyen@gmail.com", to: user.email, subject: "Tạo tài khoản thành công"
  end

end
