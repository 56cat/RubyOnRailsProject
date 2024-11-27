class Conversation < ApplicationRecord

  default_scope {order(created_at: :desc)}

  belongs_to :user
  belongs_to :brand
  has_many :messages

  validates :brand_id, presence: true
  validates :user_id, presence: true

end
