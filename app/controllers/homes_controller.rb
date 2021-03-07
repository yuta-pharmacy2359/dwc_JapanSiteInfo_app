class HomesController < ApplicationController
  def top
    @spots = Spot.page(params[:page]).reverse_order
  end

  def about
  end
end
