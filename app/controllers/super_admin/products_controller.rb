class SuperAdmin::ProductsController < SuperAdmin::SuperAdminController
  before_action :find_product, only: [:new, :edit, :update, :destroy]
  require 'csv'

  def index
    @search = Product.order(id: :desc).ransack(params[:q])
    @products = @search.result(distinct: true).page(params[:page]).per(params[:limit] || 5)
    @search_fields = 'name'
  end

  def new
  end

  def create
    product = Product.new product_params
    if product.save
      flash[:notice] = 'Thêm sản phẩm thành công'
      redirect_to edit_super_admin_product_path(product)
    else
      flash[:alert] = product.errors.full_messages.inspect
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      flash[:notice] = 'Cập nhật sản phẩm thành công'
      redirect_to edit_super_admin_product_path(@product)
    else
      flash[:alert] = @product.errors.full_messages.inspect
      render 'edit'
    end
  end

  def destroy
    if @product.destroy
      flash[:notice] = 'Xóa sản phẩm thành công'
      redirect_to super_admin_products_path
    else
      flash[:alert] = @product.errors.full_messages.inspect
    end
  end

  def delete_image
    @image = ActiveStorage::Attachment.find_by_id(params[:id])
    return flash[:alert] = 'Không tìm thấy ảnh' unless @image.present?
    if @image.purge
      @message = { success: "Xóa thành công" }
    else
      @message = { error: @image.errors.full_messages.inspect }
    end
  end

  def import
    return unless request.post?
    if params[:commit] == 'Nhập Ngay'
      @message = ImportDataCsvService.new(params[:file], current_user, current_brand).import_products
    elsif params[:commit] == 'Xếp hàng đợi'
      dir_path = Rails.root.join("public", 'file_upload')
      Dir.mkdir(dir_path) unless File.directory?(dir_path)
      file_path = File.join(dir_path, "#{Time.now.to_i}_#{params[:file].original_filename}")
      File.open(file_path, "wb") { |f| f.write(params[:file].read.force_encoding("UTF-8")) }
      InventoryProductJob.perform_later('import_products', {file: file_path, user: current_user, brand: current_brand })
      @message = ['File của bạn đã được lưu và xếp vào hàng đợi. Hệ thống sẽ thông báo cho bạn khi hoàn thành']
    end
  end

  def download_template
    send_file(
      "#{Rails.root}/public/templates/import_products_template.csv",
      filename: "import_products_template.csv",
      type: "text/csv",
      disposition: "attachment"
    )
  end

  def export
    products = Product.all
    respond_to do |format|
      format.csv { send_data "\uFEFF" + products.to_csv, type: :csv, filename: "products-#{Date.today}.csv" }
    end
  end

  def export_csv_queue
    params.permit!
    date = params[:date]
    csv = CsvQueue.create(file_name: "products-#{Time.now.strftime("%Y-%m-%d__%H-%M-%S")}.csv", status: 0)
    CsvQueueJob.perform_later(date, csv)
    redirect_to super_admin_csv_queues_path
  end

  private

  def find_product
    @product = Product.find_by(id: params[:id]) || Product.new
  end

  def product_params
    params.require(:product).permit(:name, images: [])
  end

end
