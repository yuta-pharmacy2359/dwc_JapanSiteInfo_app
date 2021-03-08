class KeywordsController < ApplicationController
  def show
    @keyword = Keyword.find(params[:id])
    @spots = @keyword.spots.page(params[:page]).reverse_order
  end

  def index
    @keywords = Keyword.page(params[:page]).reverse_order
  end
end
