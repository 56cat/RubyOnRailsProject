class ImportDataCsvService

  attr_reader :file, :current_user, :current_brand

  def initialize(file, current_user, current_brand)
    @file = file
    @file_path = file&.path
    @current_user = current_user
    @current_brand = current_brand
  end

  def import_products
    messages = []
    return messages << "Chưa chọn file"  unless file_present?
    return messages << "File không đúng định dạng"  unless file_valid?

    begin
      products = []
      CSV.foreach(@file_path, headers: true, encoding: 'bom|utf-8') do |row|
        data = row.to_h.transform_keys(&:strip)
        products << [data["Tên sản phẩm"]]
      end
      messages <<  'Không có dữ liệu'  if products.empty?

      Product.import! %w[name], products

      messages << 'Nhập hàng thành công' unless messages.present?

      return messages

    rescue => e
      return [e.message]
    end
  end

  def import_inventory_products
    message = []
    return message << "Chưa chọn file"  unless file_present?
    return message << "File không đúng định dạng"  unless file_valid?

    begin
      products = []

      CSV.foreach(@file_path, 'rb:bom|UTF-16LE', :row_sep => "\r\n", :quote_char => "\x00", headers: true) do |row|
        line = $.
        data = row.to_h.transform_keys(&:strip)
        product_id = data["Mã sản phẩm"].to_s.strip
        product_name = data['Tên sản phẩm'].to_s.strip
        sell_price = data['Giá Bán'].to_s.strip
        if product_id.blank? || product_name.blank? || sell_price.blank?
          message << "Thiếu dữ liệu dòng #{line}"
          next
        end
        product = Product.find_by(id: product_id) || Product.find_by(name: product_name)
        unless product.present?
          message << "Không tìm thấy sản phẩm ở dòng #{line}"
          next
        end
        inventory_product = InventoryProduct.find_by(product_id: product.id, brand_id: @current_brand.id)
        if inventory_product.present?
          message << "Sản phẩm #{product.name} đã có trong kho"
          next
        end
        products << { product_id: product.id, sell_price: sell_price, quantity: 0, updated_by_id: @current_user.id, brand_id: @current_brand.id }
      end

      message << "Không có dữ liệu" if products.empty? && message.blank?

      InventoryProduct.import! products

      message << "Nhập kho thành công"  unless message.present?

      return message
    rescue => e
      return [e.message]
    end
  end

  def import_import_export_history
    message = []
    return message << "Chưa chọn file"  unless file_present?
    return message << "File không đúng định dạng"  unless file_valid?
    begin
      have_data = false
      CSV.foreach(@file_path, 'rb:bom|UTF-16LE', :row_sep => "\r\n", :quote_char => "\x00", headers: true) do |row|
        line = $.
        data = row.to_h.transform_keys(&:strip)
        have_data = data.present?
        action = data["Hành động"].to_s.strip.downcase
        product_id = data["Mã sản phẩm"].to_s.strip
        product_name = data['Tên sản phẩm'].to_s.strip
        buy_price = data['Giá Nhập'].to_s.strip
        quantity = data['Số lượng'].to_s.strip
        note = data['Ghi chú'].to_s.strip
        if product_id.blank? || product_name.blank? || buy_price.blank? || action.blank? || quantity.blank?
          message << "Thiếu dữ liệu dòng #{line}"
          next
        end
        if %w[xuất nhập].exclude? action
          message << "Không tìm thấy hành động dòng #{line}"
          next
        end

        product = Product.find_by(id: product_id) || Product.find_by(name: product_name)
        inventory_product = InventoryProduct.find_by(product_id: product.id, brand_id: @current_brand.id)
        unless inventory_product.present?
          message << "Không tìm thấy sản phẩm ở dòng #{line}"
          next
        end

        action = action == 'xuất' ? "export_product" : "import_product"
        import_export_history = ImportExportHistory.new
        import_export_history.owner = inventory_product
        import_export_history.quantity = quantity
        import_export_history.buy_price = buy_price
        import_export_history.action = action
        import_export_history.note = note
        import_export_history.brand_id = @current_brand.id

        import_export_history.updated_by_id = @current_user.id

        #callback
        if import_export_history.save
        else
          message << "Lỗi #{import_export_history.errors.full_messages.join("\n")} ở sản phẩm dòng #{line}"
        end
      end
      message << "Không có dữ liệu"  unless have_data
      message << "Nhập hàng thành công"  unless message.present?
      return  message

    rescue => e
      return [e.message]
    end
  end

  def file_present?
     @file.present?
  end

  def file_valid?
    File.extname(@file) == '.csv'
  end
end