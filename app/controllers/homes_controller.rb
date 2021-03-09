class HomesController < ApplicationController
  def top
    @q = Spot.ransack(params[:q])
    @spots = @q.result(distinct: true).page(params[:page]).reverse_order
  end

  def about
  end
end
