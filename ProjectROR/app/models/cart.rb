class Cart < ApplicationRecord

  belongs_to :promotion, optional: true
  has_one :bill
  has_many :line_items
  after_commit :calculate_total

  def calculate_total
    total = self.line_items&.reload&.sum(:total_amount) || 0
    discount = self.discount || 0
    subtotal = total - discount
    if self.is_active
      self.update_columns(total: total, subtotal: subtotal, discount: discount)
    end
  end
end
