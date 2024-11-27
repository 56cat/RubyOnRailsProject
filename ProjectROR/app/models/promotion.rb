class Promotion < ApplicationRecord


  COLUMN_ATTRIBUTE_SUPER_ADMIN = [
    { column: 'name', label: 'Tên khuyến mãi' },
    { column: 'code', label: 'Mã khuyến mãi' },
    { column: 'start', label: 'Bắt đầu', data_type: 'date', sort_by: 'start' },
    { column: 'end', label: 'Kết thúc', data_type: 'date', sort_by: 'end' },
    { column: 'total_uses', label: 'Đã sử dụng' }
  ]

  ACTION_SUPER_ADMIN = ['edit']

  has_many :line_items
  has_many :promotion_histories
  validates :name, presence: true
  validates :user_apply, presence: true
  validates :kind, presence: true
  validates :start, presence: true
  validates :product_apply, presence: true, if: -> {kind == 'product'}
  validates :brand_apply, presence: true, if: -> {kind == 'product'}
  validates :code, presence: true, uniqueness: true
  before_save :reject_blank
  enum kind: { bill: 0, product: 1 }

  scope :can_using, -> {where("(promotions.start <= :now AND promotions.end >= :now)",{now: Time.now})}
  scope :apply_for_user, ->(user_id) { where("promotions.user_apply @> ?", "#{[user_id.to_s]}")}

  def reject_blank
    self.user_apply&.reject!(&:blank?)
    self.product_apply&.reject!(&:blank?)
    self.brand_apply&.reject!(&:blank?)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name code created_at updated_at start end]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[line_items promotion_histories]
  end

  def total_uses
    self.promotion_histories.size
  end

end
