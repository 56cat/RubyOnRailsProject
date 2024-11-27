class Supplier::SupplierController < ApplicationController

  before_action :admin_role

  def admin_role
    unless current_user && current_user.supplier?
      flash[:error] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end

end
