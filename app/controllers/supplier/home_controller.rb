class Supplier::HomeController < Supplier::SupplierController
  include ChartData

  def index
    date_range = (6.days.ago.beginning_of_day..Date.today.end_of_day)
    date_range = build_date_range if valid_date_params?
    @data_delivery = delivery_total_data(date_range, current_brand.id)
    @data_bill = delivery_amount_data(date_range, current_brand.id)
    respond_to do |format|
      format.html
      format.json { render json: {
        data_delivery: @data_delivery,
        data_bill: @data_bill
      } }
    end
  end

  def preview_pdf_file
    date_range = (6.days.ago.beginning_of_day..Date.today.end_of_day)
    date_range = build_date_range if valid_date_params?
    data_delivery = delivery_total_data(date_range, current_brand.id)
    url_chart_delivery = "https://quickchart.io/chart?c=#{CGI.escape(data_delivery.to_json)}"
    data_bill = delivery_amount_data(date_range, current_brand.id)
    url_chart_bill = "https://quickchart.io/chart?c=#{CGI.escape(data_bill.to_json)}"
    pdf_html = ActionController::Base.new.render_to_string(template: 'pdfs/supplier/dashboard.html.erb',
                                                           layout: 'pdf',
                                                           locals: {
                                                             url_chart_delivery: url_chart_delivery,
                                                             url_chart_bill: url_chart_bill
                                                           },
                                                           viewport_size: '1280x1024'

    )
    pdf = WickedPdf.new.pdf_from_string(pdf_html)
    file = Tempfile.new(["test", ".pdf"])
    file.binmode
    file.write pdf
    file.close

    File.open(File.expand_path(file), 'r') do |f|
      send_data pdf,
                filename: "Báo cáo #{Time.now.strftime('%d-%m-%Y')}.pdf",
                type: 'application/pdf',
                disposition: :inline
    end
    File.delete(file.path)

  end

  private

  def valid_date_params?
    params[:start_date].present? && params[:end_date].present?
  end

  def build_date_range
    start_date = params[:start_date].to_datetime.beginning_of_day
    end_date = params[:end_date].to_datetime.end_of_day
    (start_date..end_date)
  end
end