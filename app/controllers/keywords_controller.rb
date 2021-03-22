class KeywordsController < ApplicationController
  before_action :authenticate_user!, { only: [:index] }

  def show
    @keyword = Keyword.find(params[:id])
    @q = @keyword.spots.ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    @spots = @q.result.page(params[:page])
    @cookies = cookies[:favorite_spot_id]
  end

  def index
    @q = Keyword.ransack(params[:q])
    @q.sorts = 'updated_at desc' if @q.sorts.empty?
    @keywords = @q.result(distinct: true).page(params[:page])
  end
end
