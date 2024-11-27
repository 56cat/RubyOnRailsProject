class Product < ApplicationRecord
  has_many_attached :images
  has_many :line_items
  validates :name, presence: true

  COLUMN_ATTRIBUTE_SUPPLIER = [
    { column: 'id', label: '#', sort_by: 'id' },
    { column: 'name', label: 'Tên sản phẩm', sort_by: 'name' }
  ]
  COLUMN_ATTRIBUTE_SUPER_ADMIN = [
    { column: 'id', label: '#', sort_by: 'id' },
    { column: 'name', label: 'Tên sản phẩm', sort_by: 'name' }
  ]

  ACTION_SUPER_ADMIN = ["edit"]
  ACTION_SUPPLIER = ["show"]

  def self.to_csv
    attributes = %w{id name }
    GenerateCsvJob.perform_now(all, attributes)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at id name updated_at]
  end

end
