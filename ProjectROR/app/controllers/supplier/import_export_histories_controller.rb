class Supplier::ImportExportHistoriesController < Supplier::SupplierController

  def index

  end

  def new
    @import_product = ImportExportHistory.new
    @inventory_product = InventoryProduct.where(brand_id: current_brand.id)
  end

  def create
    import_note = ExportNote.new(import_export_params)
    if import_note.save
      flash[:notice] = "Nhập hàng thành công"
      redirect_to supplier_import_export_histories_path
    else
      @inventory_product = InventoryProduct.where(brand_id: current_brand.id)
      flash[:alert] = import_note.errors.full_messages.join(', ')
      render 'new'
    end
  end

  private

  def import_export_params
    params.require(:export_note).permit(
      :import_brand_id,
      :status,
      :receiver_id,
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
        :_destroy
      ]
    )
  end

end
