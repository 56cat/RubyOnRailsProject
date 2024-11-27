class SearchController < ApplicationController

  def search
    return unless params[:model].present?
    model_klass = params[:model].camelize.constantize
    @search = model_klass.ransack(params[:q])
    @records = @search.result(distinct: true).page(params[:page]).per(params[:limit] || 5)
    search_attributes = params[:q]&.permit!.to_h
    respond_to do |format|
      format.js { render template: 'shared/index.js.erb',
                         locals: {
                           records: @records,
                           namespace: params[:namespace],
                           limit: params[:limit],
                           default_query: params[:q]&.reject!{|k| k.include?"_cont"},
                           query: search_attributes
                         }}
    end
  end

  def ajax_search
    if params[:q].present? && params[:model].present?
      model = params[:model].camelize.constantize
      search_field = {"#{params[:search_field]}_cont" => params[:q]}
      search_field = search_field.merge(params[:default_search_field]&.to_unsafe_hash) if params[:default_search_field].present?
      search = model.ransack(search_field)
      records = search.result(distinct: true).map{|c| [c.id, c.public_send(params[:search_field])]}
      render json: records
    end

  end

end