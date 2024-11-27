class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception
  layout :layout
  before_action :check_brand
  before_action :authenticate_user!
  before_action :check_user_active

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  def redirect_to_root
    redirect_to public_send("#{current_user.role}_root_path")
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:name, :phone, :address, :role, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def check_brand
    if request.subdomain.present? && request.subdomain != "www"
      brand = ::Brand.find_by(domain: request.subdomain)
      unless brand.present?
        redirect_to "https://www.google.com"
      end
    end
  end

  def check_user_active
    if current_user.present? &&
      !current_user&.is_active &&
      request.base_url + request.path != edit_user_url(current_user) &&
      request.base_url + request.path != user_url(current_user)

      flash[:alert] = "Tài khoản chưa được kích hoạt vui lòng đổi mật khẩu"
      redirect_to edit_user_path(current_user)

    end
  end

  def current_brand
    ::Brand.find_by(domain: current_brand_domain) if current_brand_domain.present?
  end

  def current_brand_domain
    return if request.blank?
    request.subdomain.present? && request.subdomain != "www" ? request.subdomain : nil
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def after_sign_in_path_for(resource)
    root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def layout
    if devise_controller?
      'login_layout'
    elsif current_user.user?
      "user_layout"
    else
      "application"
    end
  end
end
