class User::LineItemsController < ApplicationController

  def index
    @line_items = LineItem.where(user_id: current_user.id, bill_id: nil)
    @bill = Bill.new
    @bill.deliveries.build
    @promotion = Promotion.apply_for_user(current_user.id).can_using
  end

end
