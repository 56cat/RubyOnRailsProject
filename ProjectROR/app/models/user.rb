class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one_attached  :image

  COLUMN_ATTRIBUTE_SUPER_ADMIN = [
    { column: 'name', label: 'Tên người dùng' },
    { column: 'role_text', label: 'Vị trí' },
    { column: 'phone', label: 'Số điện thoại' },
    { column: 'email', label: 'Email' },
    { column: 'brand_name', label: 'Đại lý' }
  ]

  ACTION_SUPER_ADMIN = ["edit"]

  enum role: {super_admin: 0, supplier: 1, client: 2, user: 3}

  has_many :line_items
  has_many :bills
  has_many :inventory_products
  has_many :import_export_histories, foreign_key: "updated_by_id"
  has_many :export_notes
  has_many :deliveries, through: :bills
  belongs_to :brand, optional: true
  has_many :conversations
  has_many :messages
  scope :not_super_admin, -> {where.not(role: :super_admin)}
  scope :is_user, -> {where(role: [:user])}

  validates :name, presence: true
  validates :role, presence: true
  validates :phone, uniqueness: true, presence: true
  validates :email, uniqueness: true, presence: true
  validates :password, confirmation: { case_sensitive: true }

  def self.ransackable_attributes(auth_object = nil)
    %w[active_at address brand_id created_at email  id is_active  name  phone  role  updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[bills brand deliveries export_notes]
  end

  def role_text
    I18n.t("users.role.#{self.role}")
  end

  def brand_name
    self.brand&.name
  end
end
