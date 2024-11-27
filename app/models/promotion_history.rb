class PromotionHistory < ApplicationRecord
  belongs_to :promotion, optional: true
  belongs_to :bill, optional: true
  belongs_to :user, optional: true
end
