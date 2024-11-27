module ChartData

  def delivery_amount_data(date_range, current_brand_id = nil)
    data = []
    %w[amount paid unpaid].each do |payment|
      label = payment_label(payment)
      color = payment_color(payment)
      chart_data = {
        label: label,
        type: 'line',
        data: Delivery.sum_by_date(date_range, payment, current_brand_id).values,
        backgroundColor: color,
        borderColor: color
      }
      data << chart_data
    end
    {
      type: 'line',
      data: {
        labels: (date_range.first.to_date..date_range.last.to_date).to_a,
        datasets:  data
      }
    }
  end

  def delivery_total_data(date_range, current_brand_id = nil)
    data = []
    %w[total cancelled received].each do |status|
      label = payment_label(status)
      color = payment_color(status)
      status = status == 'total' ? nil : status
      chart_data = {
        label: label,
        data: Delivery.total_delivery_by_date(date_range, current_brand_id, status).values,
        backgroundColor: color,
        borderColor: color
      }
      data << chart_data
    end
    {
      type: 'bar',
      data: {
        labels: (date_range.first.to_date..date_range.last.to_date).to_a,
        datasets: data
      }
    }
  end

  def product_data
    label = InventoryProduct.where(brand_id: current_brand.id).includes(:product)
                            .order(created_at: :desc).pluck("products.name")
    data = InventoryProduct.where(brand_id: current_brand.id).order(created_at: :desc).pluck(:quantity)
    [{
       label: label,
       type: 'pie',
       data: data,
       backgroundColor: [
         'rgb(255, 99, 132)',
         'rgb(54, 162, 235)',
         'rgb(255, 205, 86)'
       ],
     }]
  end

  def brand_revenue(date_range)
    {
      type: 'doughnut',
      data: {
        labels: Brand.order(id: :desc).pluck(:name),
        datasets:  [{
                      data: Delivery.amount_by_brand(date_range),
                      backgroundColor: [
                        'rgb(255, 99, 132)',
                        'rgb(54, 162, 235)',
                        'rgb(255, 205, 86)'
                      ],
                    }]
      }
    }
  end

  def payment_label(payment)
    case payment
    when 'amount'
      'Tổng tiền'
    when 'paid'
      'Đã thanh toán'
    when 'unpaid'
      'Chưa thanh toán'
    when 'total'
      'Tổng đơn'
    when 'cancelled'
      'Đơn bị hủy'
    when 'received'
      'Thành công'
    else
      ''
    end
  end

  def payment_color(payment)
    case payment
    when 'amount', 'total'
      'blue'
    when 'paid', 'received'
      'green'
    else
      'red'
    end
  end

end
