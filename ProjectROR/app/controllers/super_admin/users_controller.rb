class SuperAdmin::UsersController < SuperAdmin::SuperAdminController

  before_action :find_user, only: [:new, :edit, :update]

  def index
    @search = User.not_super_admin.order(created_at: :desc).ransack(params[:q])
    @users = @search.result(district: true).page(params[:page]).per(params[:limit] || 5)
    @search_fields = 'name_or_phone_or_email'
    @default_query = { "role_not_eq": 0 }
    @filter_fields = [
      {
        id: 'role_eq',
        label: 'Vị trí',
        options: User.roles.slice(:supplier, :user).map{|k,v| ["#{t("users.role.#{k}")}",v]}
      }
    ]
  end

  def new

  end

  def create
    user = User.new(user_params)
    random_password = Devise.friendly_token.first(6)
    user.password = random_password
    user.password_confirmation = random_password
    if user.save
      UserJob.perform_later(user, random_password)
      flash[:notice] = "Tạo người dùng thành công"
      redirect_to edit_super_admin_user_path(user)
    else
      flash[:alert] = user.errors.full_messages.join("\n")
      render 'new'
    end
  end

  def edit
  end

  def update
    user_attributes = user_params
    unless user_params[:password].present?
      user_attributes = user_params.except('password', 'password_confirmation')
    end
    if @user.update(user_attributes)
      flash[:notice] = 'Cập nhật thông tin thành công'
      redirect_to edit_super_admin_user_path(@user)
    else
      flash[:alert] = @user.errors.full_messages.join('<br>')
      render 'edit'
    end
  end

  private

  def find_user
    @user = User.find_by(id: params[:id]) || User.new
  end

  def user_params
    params.require(:user).permit(
      :name,
      :phone,
      :email,
      :address,
      :old_password,
      :password,
      :role,
      :brand_id,
      :password_confirmation,
      :image)
  end
end