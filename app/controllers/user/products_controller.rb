class User::ProductsController < ApplicationController

  def index
    @search = InventoryProduct.where.not(quantity: 0).order(id: :desc).ransack(params[:q])
    @inventory_products = @search.result(district: true).page(params[:page]).per(8)
    render 'index'
  end
end
