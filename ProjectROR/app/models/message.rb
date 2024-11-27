class Message < ApplicationRecord

  default_scope {order(created_at: :desc)}

  belongs_to :user
  belongs_to :conversation

  validates :content, presence: true

end
