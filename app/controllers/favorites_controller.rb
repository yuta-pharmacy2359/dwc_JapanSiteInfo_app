class FavoritesController < ApplicationController

  def create
    @spot = Spot.find(params[:spot_id])
    if current_user.nil?
      @favorite = Favorite.new(spot_id: @spot.id)
    else
      @favorite = current_user.favorites.new(spot_id: @spot.id)
    end
    @favorite.save
  end

  def destroy
    @spot = Spot.find(params[:spot_id])
    @favorite = current_user.favorites.find_by(spot_id: @spot.id)
    @favorite.destroy
  end

end
