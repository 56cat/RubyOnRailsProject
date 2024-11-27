class Bill < ApplicationRecord

  has_many :line_items, as: :owner
  has_many :deliveries
  has_many :promotion_histories
  belongs_to :promotion, optional: true
  belongs_to :user
  # enum status: {completed: 0, cancelled: 1}
  enum payment_method: { cod: 0, transfer: 1 }
  attr_accessor :line_item_ids
  accepts_nested_attributes_for :deliveries
  accepts_nested_attributes_for :line_items

  validate :validate_promotion
  after_create :add_code_bill
  after_create :create_promotion_history, if: -> {self.promotion.present?}
  scope :for_date_range, -> (start_date, end_date) { where(created_at: start_date.beginning_of_day..end_date.end_of_day) }
  scope :sum_by_date, -> { group('date(created_at)').sum(:amount) }

  COLUMN_ATTRIBUTE_SUPER_ADMIN = [
    { column: 'code', label: "Mã hóa đơn", sort_by: 'id'},
    { column: 'user_name', label: 'Tên khách' },
    { column: 'total', label: 'Tổng tiền', data_type: 'currency', sort_by: 'id'  },
    { column: 'payment_method_text', label: 'Hình thức thanh toán' }
  ]

  ACTION_SUPER_ADMIN = ["show"]

  def user_name
    self.user.name
  end

  def payment_method_text
    I18n.t("bill.payment_method.#{self.payment_method}")
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[amount code created_at discount id payment_method promotion_id total updated_at user_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[deliveries line_items promotion promotion_histories user]
  end

  def validate_promotion
    promotion = self.promotion

    return unless promotion.present?

    return errors.add(:promotion, 'không hoạt động') unless promotion_active?(promotion)

    return errors.add(:promotion, 'đã hết lượt dùng') unless promotion_still_uses?(promotion)

    return errors.add(:promotion, 'không áp dụng cho khách hàng này') unless promotion_for_user?(promotion)

    return errors.add(:promotion, 'sản phẩm không được áp dụng') unless promotion_for_product?(promotion)

  end

  def promotion_active?(promotion)
    promotion.start.beginning_of_day <= Time.now && promotion.end.end_of_day >= Time.now
  end

  def promotion_still_uses?(promotion)
    promotion.promotion_histories.size < promotion.max_uses
  end

  def promotion_for_user?(promotion)
    promotion.user_apply.include?(self.user_id.to_s)
  end

  def promotion_for_product?(promotion)
    return true unless promotion.kind == 'product'
    line_items =  self.line_items.includes(:target).to_a.select{|c| c.promotion_id.present?}
    return true unless line_items.present?
    line_items.any? { |line_item| promotion.product_apply.include?(line_item.target.product_id.to_s) && promotion.brand_apply.include?(line_item.target.brand_id.to_s) }
  end

  def add_code_bill
    if self.code.blank?
      self.update_column("code", "HD-#{self.id}")
    end
  end

  def create_promotion_history
    if self.promotion_id.present?
      PromotionHistory.create!(promotion_id: self.promotion_id, user_id: self.user_id, bill_id: self.id)
    end
  end

  def self.sum_by_date(start_date, end_date)
    res = for_date_range(start_date, end_date).group('date(created_at)').sum(:amount)
    with_zero_days(start_date, end_date, res)
  end

  def self.with_zero_days(start_date, end_date, res)
    data_range = (start_date.to_date..end_date.to_date).to_a
    hash = {}
    data_range.each do |date|
      hash[date] = res[date] || 0
    end
    hash
  end

end
