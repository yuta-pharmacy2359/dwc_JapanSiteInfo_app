class KeywordsController < ApplicationController
  def show
    @keyword = Keyword.find(params[:id])
    @q = @keyword.spots.ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    @spots = @q.result.page(params[:page])
    @cookies = cookies[:favorite_spot_id]
  end

  def index
    @q = Keyword.ransack(params[:q])
    @keywords = @q.result(distinct: true).page(params[:page]).reverse_order
  end
end
