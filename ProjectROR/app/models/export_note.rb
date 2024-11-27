class ExportNote < ApplicationRecord

  COLUMN_ATTRIBUTE_SUPPLIER = [
    { column: 'code', label: 'Phiếu', sort_by: 'id' },
    { column: 'kind_text', label: 'Loại', sort_by: 'kind'},
    { column: 'total_product', label: 'Số lượng sản phẩm' }
  ]
  ACTION_SUPPLIER = ['show']

  enum status: { exported: 0, received: 1}
  enum kind: { import_note: 0, export_note: 1 }
  has_many :line_items, as: :owner
  has_many :import_export_histories, as: :target
  accepts_nested_attributes_for :import_export_histories

  belongs_to :user
  belongs_to :brand

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at export_brand_id exporter_id id import_brand_id kind note receiver_id status updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[brand_export brand_import exporter import_export_histories line_items receiver]
  end

  def total_product
    self.import_export_histories.size
  end

  def kind_text
    I18n.t("note.kind.#{self.kind}")
  end

  def status_text
    I18n.t("note.status.#{self.status}")
  end

  def code
    "Note-#{self.id}"
  end

end
