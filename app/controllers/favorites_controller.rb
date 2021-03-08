class FavoritesController < ApplicationController

  def create
    @spot = Spot.find(params[:spot_id])
    if current_user.nil?
      @favorite = Favorite.new(spot_id: @spot.id)
    else
      @favorite = current_user.favorites.new(spot_id: @spot.id)
    end
    @favorite.save
    @user= @spot.user
    @spots = @user.spots.page(params[:page]).reverse_order
    @favorites_count = 0
    @spots.each do |spot|
      @favorites_count += spot.favorites.count
    end
  end

  def destroy
    @spot = Spot.find(params[:spot_id])
    @favorite = current_user.favorites.find_by(spot_id: @spot.id)
    @favorite.destroy
    @user= @spot.user
    @spots = @user.spots.page(params[:page]).reverse_order
    @favorites_count = 0
    @spots.each do |spot|
      @favorites_count += spot.favorites.count
    end
  end

end
