class SuperAdmin::PromotionsController < SuperAdmin::SuperAdminController

  before_action :find_promotion, except: [:index]

  def index
    @search = Promotion.order(id: :desc).ransack(params[:q])
    @promotions = @search.result(distinct: true).page(params[:page]).per(params[:limit] || 5)
    @search_fields = 'name_or_code'
  end

  def new
  end

  def create
    promotion = Promotion.new promotion_params
    if promotion.save
      flash[:notice] = 'Tạo mới mã khuyến mại thành công'
      redirect_to edit_super_admin_promotion_path(promotion)
    else
      flash[:alert] = promotion.errors.full_messages.inspect
      render 'new'
    end

  end

  def show
    @promotion_histories = @promotion.promotion_histories.order(created_at: :asc).page(params[:page]).per(10)

  end

  def edit
  end


  def update
    if @promotion.update(promotion_params)
      flash[:notice] = 'Cập nhật mã thành công'
      redirect_to edit_super_admin_promotion_path(@promotion)
    else
      flash[:alert] = @promotion.errors.full_messages.inspect
      render 'new'
    end
  end

  def destroy
    if @promotion.destroy
      flash[:notice] = 'Xóa mã thành công'
      redirect_to super_admin_promotion_path
    else
      flash[:alert] = @promotion.errors.full_messages.inspect
    end
  end

  private

  def find_promotion
    @promotion = Promotion.find_by(id: params[:id]) || Promotion.new
    return flash[:alert] = 'Không tìm thấy mã' unless @promotion.present?
  end

  def promotion_params
    params.require(:promotion).permit(:name,
                                      :code,
                                      :percent_discount,
                                      :kind,
                                      :max_amount,
                                      :max_uses,
                                      :start,
                                      :end,
                                      user_apply: [],
                                      product_apply: [],
                                      brand_apply: [],
                                      )
  end

end