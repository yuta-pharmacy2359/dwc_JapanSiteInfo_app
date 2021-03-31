class HomesController < ApplicationController
  def top
    @q = Spot.ransack(params[:q])
    @spots = @q.result(distinct: true).page(params[:page]).includes(:favorites).reverse_order
    @cookies = cookies[:favorite_spot_id]
  end

  def about
  end
end
