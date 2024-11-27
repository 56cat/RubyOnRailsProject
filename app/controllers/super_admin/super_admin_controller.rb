class SuperAdmin::SuperAdminController < ApplicationController
  before_action :supper_admin_role?


  def supper_admin_role?
    unless current_user && current_user.super_admin?
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end
end