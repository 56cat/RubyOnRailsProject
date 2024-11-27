class Brand < ApplicationRecord

  enum kind: { supplier: 0, client: 1}
  has_many :users
  has_many :import_export_histories
  has_many :inventory_products
  has_many :bills
  has_many :products
  has_many :line_items
  has_many :conversations
  validates :name, presence: true
  validates :domain, presence: true, uniqueness: true, domain: true
  has_many :export_notes

  scope :is_supplier, -> {where(kind: :supplier)}
  scope :is_client, -> {where(kind: :client)}


  COLUMN_ATTRIBUTE_SUPER_ADMIN = [
    { column: 'name', label: 'Tên đại lý' },
    { column: 'domain', label: 'Domain' }
  ]

  ACTION_SUPER_ADMIN = ["edit"]

  def self.ransackable_attributes(auth_object = nil)
    %w[name domain created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[bills import_export_histories inventory_products line_items products users]
  end

end
