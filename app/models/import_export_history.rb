class ImportExportHistory < ApplicationRecord

  belongs_to :owner,optional: true, polymorphic: true
  belongs_to :target,optional: true, polymorphic: true
  belongs_to :brand
  belongs_to :updater,  class_name: 'User', foreign_key: 'updated_by_id'
  after_create :update_quantity_product
  enum action: {import_product: 0, export_product: 1, cancelled: 2, refund: 3}
  validates_numericality_of :quantity, :less_than_or_equal_to  => Proc.new {|export| export.owner.quantity }, if: -> {self.action == 'export_product'}


  COLUMN_ATTRIBUTE_SUPPLIER = [
    { column: 'product_name', label: 'Tên sản phẩm', sort_by: 'product_id' },
    { column: 'buy_price', label: 'Giá', sort_by: 'buy_price', data_type: 'currency' },
    { column: 'quantity', label: 'Số lượng', sort_by: 'name' },
    { column: 'note', label: 'Note' }
  ]

  def product_name
    self.owner.product.name
  end

  def update_quantity_product
    quantity = %w[import_product refund].include?(self.action) ? self.owner.quantity + self.quantity : self.owner.quantity - self.quantity
    self.owner.update!(quantity: quantity, updated_by_id: self.updated_by_id)
  end



end
