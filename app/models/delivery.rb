class Delivery < ApplicationRecord
  include DeliveriesHelper
  COLUMN_ATTRIBUTE_SUPPLIER = [
    { column: 'bill_code', label: 'Mã hóa đơn', sort_by: 'bill_id' },
    { column: 'code', label: 'Mã vận chuyển', sort_by: 'id'},
    { column: 'name_customer', label: 'Khách hàng	', sort_by: 'status' },
    { column: 'payment_method_label', label: 'Hình thức thanh toán' },
    { column: 'amount', label: 'Số tiền cần thanh toán', data_type: 'currency' },
    { column: 'paid', label: 'Đã thanh toán', data_type: 'currency' },
    { column: 'unpaid', label: 'Chưa thanh toán', data_type: 'currency' },
    { column: 'status_label', label: 'Trạng thái	' }
  ]

  COLUMN_ATTRIBUTE_SUPER_ADMIN = [
    { column: 'bill_code', label: 'Mã hóa đơn', sort_by: 'bill_id' },
    { column: 'code', label: 'Mã vận chuyển', sort_by: 'id'},
    { column: 'brand_name', label: 'Đại lý', sort_by: 'id'},
    { column: 'name_customer', label: 'Khách hàng	'},
    { column: 'amount', label: 'Số tiền cần thanh toán', data_type: 'currency' },
    { column: 'paid', label: 'Đã thanh toán', data_type: 'currency' },
    { column: 'unpaid', label: 'Chưa thanh toán', data_type: 'currency' },
    { column: 'status_label', label: 'Trạng thái	' }
  ]

  ACTION_SUPPLIER = ["show"]
  ACTION_SUPER_ADMIN = ["show"]

  belongs_to :bill
  belongs_to :brand
  has_many :line_items, through: :bill
  belongs_to :user, optional: true
  belongs_to :updater, optional: true, class_name: 'User', foreign_key: 'updated_by_id'
  enum status: {created: 0, verified: 1, pickup:2, transport: 3, received:4, cancelled: 5}
  after_create :add_code_delivery
  after_create :send_mail_create_delivery_to_supplier, if: -> {self.updater.user?}
  after_update :send_mail_update_status_to_customer, if: -> {self.previous_changes[:status].present? && self.status != 'received' && self.updater.supplier?}
  after_update :export_product, if: -> {self.previous_changes[:status].present? && self.status == 'pickup'}
  after_update :paid_delivery, if: -> {self.previous_changes[:status].present? && self.status == 'received'}
  before_create  :add_attribute

  scope :for_date_range, -> (start_date, end_date) {where(created_at: start_date.beginning_of_day..end_date.end_of_day)}
  scope :count_by_date, -> {group('date(created_at)').count}
  scope :created_in, ->  (date) {where(created_at: date)}
  scope :is_brand, ->(brand_id) {where(brand_id: brand_id)}
  scope :by_status, ->(status) {where(status: status)}

  validate :update_status, if: -> {self.status_changed?}

  def self.ransackable_attributes(auth_object = nil)
    %w[status code address phone amount brand_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[brand bill user]
  end

  def add_attribute
    self.amount = self.line_items.where(brand_id: self.brand_id).to_a.sum(&:amount)
    self.unpaid = self.bill.payment_method == 'cod' ? self.line_items.where(brand_id: self.brand_id).to_a.sum(&:amount) : 0
    self.paid = self.bill.payment_method == 'cod' ? 0 : self.line_items.where(brand_id: self.brand_id).to_a.sum(&:amount)
    self.user_id = self.bill.user_id
    self.updated_by_id = self.bill.user_id
  end

  def update_status
    if self.changes[:status][0] == 'received'
      return errors.add(:delivery, 'đã hoàn thành')
    end
    if self.changes[:status][0] == 'cancelled'
      return errors.add(:delivery, 'đã bị hủy')
    end
    if self.status == 'cancelled' && %w[created verified].exclude?(self.changes[:status][0])
      return errors.add(:delivery, 'không thể hủy')
    end
  end

  def add_code_delivery
    if self.code.blank?
      self.update_column("code","VC-#{self.id}")
    end
  end

  def payment_method_label
    payment_method(self.bill&.payment_method)
  end

  def status_label
    delivery_status(self.status)
  end

  def bill_code
    self.bill.code
  end

  def name_customer
    self.user.name
  end

  def brand_name
    self.brand.name
  end

  def bill_paid
    if self.bill.payment_method == 'cod'
      self.amount
    elsif self.bill.payment_method == 'transfer'
      0
    end
  end

  def self.sum_by_date(date_range, payment, current_brand_id = nil)
    res =  Delivery.where(created_at: date_range).where.not(status: 'cancelled')
    res = res.is_brand(current_brand_id) if current_brand_id.present?
    res = res.group("date(created_at)").sum(payment)
    with_zero_days(date_range, res)
  
  end


  def self.total_delivery_by_date(date_range, current_brand_id = nil, status = nil)
    res = Delivery.where(created_at: date_range)
    res = res.is_brand(current_brand_id) if current_brand_id.present?
    res = res.by_status(status) if status.present?
    res = res.group('date(created_at)').count
    with_zero_days(date_range, res)
    
  end


  def self.amount_by_brand(date_range)
    brand_ids = Brand.order(id: :desc).pluck(:id)
    res = Delivery.where(created_at: date_range).where.not(status: 'cancelled').group(:brand_id).sum(:amount)
    hash = {}
    brand_ids.each do |brand_id|
      hash[brand_id] = res[brand_id] || 0
    end
    hash.values
  end



  def self.with_zero_days(data_range, res)
    data_range = ( data_range.first.to_date..data_range.last.to_date).to_a
    hash = {}
    data_range.each do |date|
      hash[date] = res[date] || 0
    end
    hash
  end


  def next_status
    Delivery.statuses.key(Delivery.statuses[self.status]+1)
  end

  def send_mail_create_delivery_to_supplier
    DeliveryJob.perform_later('send_mail_create_delivery', {delivery: self})
  end

  def send_mail_update_status_to_customer
    DeliveryJob.perform_later('send_mail', {user: self.bill&.user, delivery: self })
  end

  def paid_delivery
    if self.bill.payment_method == 'cod'
      self.update!(paid: self.unpaid, unpaid: 0)
    end
  end

  def export_product
    line_items = self.line_items.where(brand_id: self.brand_id)
    line_items&.each do |line_item|
      #vãn phải để như này để gọi call back ạ
      ImportExportHistory.create!(owner: line_item.target, quantity: line_item.quantity, target: line_item, action: 'export_product', brand_id: line_item.brand_id, updated_by_id: self.updated_by_id)
    end
  end
end
