class Login::SessionsController < Devise::SessionsController
  prepend_before_action :check_brand, only: [:create]



  private

  def check_brand
    subdomain = request.subdomain.present? ? request.subdomain : nil
    user = User.find_by(email: sign_in_params["email"])
    brand = Brand.find_by(domain: subdomain)
    if user  && (subdomain_mismatch?(brand, user) || subdomain_missing?(brand, user))
      flash[:alert] = "Tài khoản không tồn tại"
      redirect_to new_user_session_path
    end
  end

  def subdomain_mismatch?(brand, user)
    brand && user.brand_id != brand.id && !user.user?
  end

  def subdomain_missing?(brand, user)
    brand.nil? && !user.super_admin? && !user.user?
  end
end