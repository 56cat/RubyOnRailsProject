class Login::RegistrationsController < Devise::RegistrationsController

  def create
    password_random = ([*('A'..'Z'),*('0'..'9')] - %w(I O 0 1)).shuffle[0, 6].join
    build_resource(sign_up_params)
    resource.send_mail_created_at = Time.zone.now
    unless resource.password.present?
      resource.password = password_random
      resource.password_confirmation = password_random
    end
    if resource.save
      UserJob.perform_later(resource, password_random)
      flash[:notice] = "Vui lòng kiểm tra email"
      redirect_to new_user_session_path
    else
      flash[:alert] = resource.errors.full_messages.join("<br />")
      respond_with resource
    end
  end


  # protected
  # def sign_up_params
  #   params.require(:user).permit(:name, :phone, :email, :password, :password_confirmation)
  # end
end
