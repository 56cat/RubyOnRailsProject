class LineItem < ApplicationRecord

  # belongs_to :bill, optional: true
  # belongs_to :product, optional: true
  belongs_to :user, optional: true
  belongs_to :promotion, optional: true
  belongs_to :owner, optional: true, polymorphic: true
  belongs_to :target, optional: true, polymorphic: true
  belongs_to :brand, optional: true

  enum status: { not_in_cart: 0, in_cart: 1 }

  validate :quantity_product

  # after_create :create_export_inventory_product
  before_save :add_current_user

  def add_current_user
    self.user_id = self.owner.user_id
  end

  def quantity_product
    if self.quantity > self.target.quantity
      errors.add(:quantity, 'Số lượng sản phẩm không đủ')
    end
  end

  def total_amount
    self.quantity * self.price
  end

  def amount
    self.discount.present? ? self.total_amount - self.discount : self.total_amount
  end

  # def create_export_inventory_product
  #   ImportExportHistory.create!(owner: self.target, quantity: self.quantity, target: self, action: 'export_product', brand_id: self.brand_id, updated_by_id: self.user_id)
  # end
end
