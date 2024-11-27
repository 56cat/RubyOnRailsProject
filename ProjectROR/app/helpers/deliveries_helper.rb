module DeliveriesHelper

  def payment_method(method)
    if method.present?
      "<span class='badge bg-#{method == 'cod' ? 'danger' : 'success'}' >#{I18n.t("bill.payment_method.#{method}")}</span> </span>".html_safe
    end
  end

  def delivery_status(status)
    if status == 'created'
      "<span class=' btn btn-info'>#{I18n.t("delivery.status.#{status}")}</span>".html_safe
    elsif status == 'verified'
      "<span class=' btn btn-primary'>#{I18n.t("delivery.status.#{status}")}</span>".html_safe
    elsif status == 'pickup'
      "<span class=' btn btn-warning'>#{I18n.t("delivery.status.#{status}")}</span>".html_safe
    elsif status == 'transport'
      "<span class='btn btn-danger'>#{I18n.t("delivery.status.#{status}")}</span>".html_safe
    elsif status == 'received'
      "<span class='btn btn-success'>#{I18n.t("delivery.status.#{status}")}</span>".html_safe
    elsif status == 'cancelled'
      "<span class='btn btn-secondary'>#{I18n.t("delivery.status.#{status}")}</span>".html_safe
    end
  end

  def link_to_status(user, delivery)
    status = delivery.status
    next_status = delivery.next_status
    new_status = nil
    if user.supplier? && !%w[transport received cancelled].include?(status)
      new_status = next_status
    end
    if user.user?
      new_status =
        case status
        when 'created', 'verified' then
          'cancelled'
        when 'transport' then
          'received'
        else
          nil
        end
    end
    if new_status
      if user.supplier?
        "#{link_to delivery_status(new_status), change_status_supplier_delivery_path(delivery, status: new_status), method: :post, remote: true}
        #{ (status == 'created' || status == 'verified') ?
             "#{link_to delivery_status('cancelled'), '', { id: "link-to-modal-cancel", "data-href" => change_status_supplier_delivery_path(delivery, status: 'cancelled') }}"
             : ""
        }".html_safe
      elsif user.user?
        if new_status == 'cancelled'
          link_to delivery_status(new_status), '', { id: "link-to-modal-cancel", "data-href" => change_status_user_delivery_path(delivery, status: new_status) }
        else
          link_to delivery_status(new_status), change_status_user_delivery_path(delivery, status: new_status), method: :post, remote: true
        end
      end
    end
  end

end
