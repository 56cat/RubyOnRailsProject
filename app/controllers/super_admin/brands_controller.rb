class SuperAdmin::BrandsController < SuperAdmin::SuperAdminController
  before_action :find_brand, only: [:new, :edit, :update, :destroy]

  def index
    @search = Brand.order(created_at: :desc).ransack(params[:q])
    @brands = @search.result(district: true).page(params[:page]).per(params[:limit] || 5)
    @search_fields = 'name'
  end

  def new
  end

  def create
    @brand = Brand.new brand_params
    if @brand.save
      flash[:notice] = "Thêm mới thương hiệu thành công"
      redirect_to edit_super_admin_brand_path(@brand)
    else
      flash[:alert] = @brand.errors.full_messages.join("\n")
      render 'new'
    end
  end

  def edit
  end

  def update
    if @brand.update(brand_params)
      flash[:notice] = "Cập thương hiệu thành công"
      redirect_to edit_super_admin_brand_path(@brand)
    else
      flash[:alert] = @brand.errors.full_messages.inspect
      render 'edit'
    end
  end

  def destroy
    if @brand.destroy
      flash[:notice] = 'Xóa thương hiệu'
      redirect_to super_admin_brands_path
    else
      flash[:alert] = @brand.errors.full_messages.inspect
    end
  end

  private

  def find_brand
    @brand = Brand.find_by(id: params[:id]) || Brand.new
    return flash[:alert] = 'Không tìm thấy thương hiệu' unless @brand.present?
  end

  def brand_params
    params.require(:brand).permit(:name,:kind, :domain)
  end
end
