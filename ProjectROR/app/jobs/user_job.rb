class UserJob < ApplicationJob
  queue_as :default

  def perform(user, password)
    UserMailer.send_mail_after_registration(user, password).deliver_later
  end
end
