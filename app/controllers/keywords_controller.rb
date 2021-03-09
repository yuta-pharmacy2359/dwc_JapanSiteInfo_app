class KeywordsController < ApplicationController
  def show
    @keyword = Keyword.find(params[:id])
    @spots = @keyword.spots.page(params[:page]).reverse_order
  end

  def index
    @q = Keyword.ransack(params[:q])
    @keywords = @q.result(distinct: true).page(params[:page]).reverse_order
  end
end
