class FavoritesController < ApplicationController

  def create
    @spot = Spot.find(params[:spot_id])
    @favorite = current_user.favorites.new(spot_id: @spot.id)
    @favorite.save
    redirect_back(fallback_location: top_path)
  end

  def destroy
    @spot = Spot.find(params[:spot_id])
    @favorite = current_user.favorites.find_by(spot_id: @spot.id)
    @favorite.destroy
    redirect_back(fallback_location: top_path)
  end

end
