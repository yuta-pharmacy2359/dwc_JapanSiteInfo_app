class RankingsController < ApplicationController
  before_action :authenticate_user!, { only: [:user_favorite, :spot_favorite] }

  def user_favorite
    spots = []

    favorites = Favorite.group("spot_id").select("spot_id, count(spot_id) as count_spot_id")
    favorites.each do |fav|
      spots.append(id: fav.spot_id, user_id: Spot.find(fav.spot_id).user_id, count: fav.count_spot_id)
    end

    @summary = {}
    spots.each do |spot|
      hash = spot[:user_id].to_s
      if @summary[hash] == nil
        @summary[hash] = 0
      end
      @summary[hash] += spot[:count]
    end
  end

  def spot_favorite
    @all_ranks = Spot.create_spot_favorite_ranks
  end

end
