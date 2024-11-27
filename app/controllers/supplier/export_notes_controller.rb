class Supplier::ExportNotesController < Supplier::SupplierController

  def index
    @search = ExportNote.where(brand_id: current_brand.id).ransack(params[:q])
    @import_export_note = @search.result(distinct: true).page(params[:page]).per(params[:limit] || 5)
    @default_query = {'brand_id': current_brand.id }
    @search_fields = 'note'
    @filter_fields = [
      {
        id: 'kind_eq',
        label: 'Loại phiếu',
        options: ExportNote.kinds.map{|k,v| ["#{t("note.kind.#{k}")}",v]}
      },
      {
        id: 'status_eq',
        label: 'Trạng thái',
        options: ExportNote.statuses.map{|k,v| ["#{t("note.status.#{k}")}",v]}
      }
    ]
  end

  def new
    @export_note = ExportNote.new
    @inventory_product = InventoryProduct.where(brand_id: current_brand.id)
  end

  def show
    @note = ExportNote.find_by(id: params[:id])
    return redirect_to(supplier_export_notes_path, flash[:alert] = 'Không tìm thấy phiếu') unless @note.present?
  end

  def create
    import_export_histories_attributes = export_note_params[:import_export_histories_attributes].to_h.each do |_key, value|
         value['action'] = export_note_params[:kind] == 'import_note' ? 'import_product' : 'export_product'
    end
    @export_note = ExportNote.new(export_note_params.merge({"import_export_histories_attributes"=>import_export_histories_attributes}))
    if @export_note.save
      flash[:notice] = "Tạo phiếu thành công"
      redirect_to supplier_export_notes_path
    else
      flash[:notice] = @export_note.errors.full_messages.join("\n")
      render 'new'
    end
  end

  def download_template
      send_file(
        "#{Rails.root}/public/templates/export_note_template.csv",
        filename: "export_note_template.csv",
        type: "text/csv",
        disposition: "attachment"
      )
  end

  def import
    return unless request.post?
    if params[:commit] == 'Nhập Ngay'
      @message = ImportDataCsvService.new(params[:file], current_user, current_brand).import_import_export_history
    elsif params[:commit] == 'Xếp hàng đợi'
      dir_path = Rails.root.join("public", 'file_upload')
      Dir.mkdir(dir_path) unless File.directory?(dir_path)
      file_path = File.join(dir_path, "#{Time.now.to_i}_#{params[:file].original_filename}")
      File.open(file_path, "wb") { |f| f.write(params[:file].read.force_encoding("UTF-8")) }
      InventoryProductJob.perform_later('import_import_export_history', {file: file_path, user: current_user, brand: current_brand })
      @message = ['File của bạn đã được lưu và xếp vào hàng đợi. Hệ thống sẽ thông báo cho bạn khi hoàn thành']
    end

  end



  private

  def export_note_params
    params.require(:export_note).permit(
      :import_brand_id,
      :status,
      :brand_id,
      :user_id,
      :note,
      :kind,
      import_export_histories_attributes: [
        :id,
        :owner_type,
        :owner_id,
        :quantity,
        :buy_price,
        :note,
        :action,
        :brand_id,
        :updated_by_id,
        :buy_price,
        :_destroy
      ]
    )
  end
end
