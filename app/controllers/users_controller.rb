class UsersController < ApplicationController

  before_action :find_user

  def edit
  end

  def update
    if user_params[:old_password].present? && user_params[:password].present? && user_params[:password_confirmation].present?
      unless @user.valid_password?(user_params[:old_password])
        flash[:alert] = 'Sai mật khẩu cũ'
        render 'edit'
        return
      end
      user_attributes = user_params.except('old_password')
      user_attributes[:is_active] = true
      user_attributes[:active_at] = Time.zone.now
    else
      user_attributes = user_params.except('old_password', 'password', 'password_confirmation')
    end
    if @user.update(user_attributes)
      flash[:notice] = 'Cập nhật thông tin thành công'
      redirect_to edit_user_path(@user)
    else
      flash[:alert] = @user.errors.full_messages.join('<br>')
      render 'edit'
    end
  end

  private

  def find_user
    @user = User.find_by(id: params[:id])
    return flash[:alert] = 'Không tìm thấy người dùng' unless @user.present?
  end

  def user_params
    params.require(:user).permit(:name, :phone, :email, :address, :old_password, :password, :password_confirmation)
  end
end