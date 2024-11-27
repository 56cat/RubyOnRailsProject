class InventoryProduct < ApplicationRecord

  COLUMN_ATTRIBUTE_SUPPLIER = [
    { column: 'product_name', label: 'Tên sản phẩm', sort_by: 'product_id' },
    { column: 'sell_price', label: 'Giá bán', sort_by: 'sell_price', data_type: 'currency' },
    { column: 'quantity', label: 'Số lượng', sort_by: 'quantity' }
  ]
  ACTION_SUPPLIER = ["edit", 'show']




  belongs_to :product
  belongs_to :brand
  belongs_to :updater,  class_name: 'User', foreign_key: 'updated_by_id'
  has_many :import_export_histories, as: :owner
  has_many :inventory_products, as: :target

  validates_uniqueness_of :product_id, scope: :brand_id, on: :create
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def product_name
    self.product.name
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[brand_id  id product_id quantity sell_price updated_at updated_by_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[brand import_export_histories inventory_products product updater]
  end

end
