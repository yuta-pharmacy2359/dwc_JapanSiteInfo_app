class FavoritesController < ApplicationController
  def create
    @spot = Spot.find(params[:spot_id])
    if current_user.nil?
      if cookies[:favorite_spot_id].nil?
        cookies.permanent[:favorite_spot_id] = @spot.id.to_s
      else
        cookies.permanent[:favorite_spot_id] = cookies.permanent[:favorite_spot_id] + "," + @spot.id.to_s
      end
      Favorite.create(user_id: nil, spot_id: @spot.id)
      @favorites_count = @spot.favorites.count
      @cookies = cookies[:favorite_spot_id]
    else
      @favorite = current_user.favorites.new(spot_id: @spot.id)
      @favorite.save
      @favorites_count = @spot.favorites.count
    end
    @user = @spot.user
    @spots = @user.spots.page(params[:page]).reverse_order
    @user_all_spots = @user.spots
    fav_count = @user_all_spots.joins(:favorites).group("spots.user_id").count("favorites.id")
    @user_all_favorites_count = fav_count.present? ? fav_count.fetch(@user.id) : 0
    if current_user.present?
      @spot.create_notification_by(current_user)
      respond_to do |format|
        format.html {redirect_to request.referrer}
        format.js
      end
    end
  end

  def destroy
    @spot = Spot.find(params[:spot_id])
    if current_user.nil?
    else
      @favorite = current_user.favorites.find_by(spot_id: @spot.id)
      @favorite.destroy
    end
    @user = @spot.user
    @spots = @user.spots.page(params[:page]).reverse_order
    @favorites_count = @spot.favorites.count
    @user_all_spots = @user.spots
    fav_count = @user_all_spots.joins(:favorites).group("spots.user_id").count("favorites.id")
    @user_all_favorites_count = fav_count.present? ? fav_count.fetch(@user.id) : 0
  end
end
