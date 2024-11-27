module ApplicationHelper
  extend ActiveSupport::Concern


  def format_currency(currency)
    number_to_currency(currency || 0, {locale: :vi, unit: 'đ', precision: 0, delimiter: ','})
  end


  def current_brand
    ::Brand.find_by(domain: current_brand_domain) if current_brand_domain.present?
  end

  def render_row_data(data, type)
    return unless data.present?
    case type
    when 'boolean'
      data ? '<i class="fa-solid fa-check"></i>'.html_safe   : '<i class="fa-solid fa-xmark"></i>'.html_safe
    when 'currency'
      format_currency(data)
    when 'date_time'
      data.strftime('%H:%M %d/%m/%Y')
    when 'date'
      data.strftime('%d/%m/%Y')
    when 'time'
      data.strftime('%H:%M')
    else
      data
    end
  end

  def search_for_ransack(records, attributes_to_search = nil)
    attributes_to_search = records.column_names if attributes_to_search.nil?
    fields = ""
    options = { class: "form-control search-field" }

    attributes_to_search.each do |column|
      label_text = column.humanize
      input_field_tag =
        case records.columns_hash[column]&.type
        when :integer, :float
          number_field_tag(eq_field_name(column), "", options)
        when :datetime
          date_field_tag(eq_field_name(column), "", options)
        else
          field_name = "q[#{column}_cont]"
          text_field_tag(field_name, "", options)
        end
      label_tag = label_tag(field_name, label_text)

      fields << content_tag(:div, label_tag + input_field_tag, class: "search-field-wrapper mx-2")
    end

    fields.html_safe
  end

  def eq_field_name(column)
    "q[#{column}_eq]"
  end



  def current_brand_domain
    return if request.blank?
    request.subdomain.present? && request.subdomain != "www" ? request.subdomain : nil
  end
end
