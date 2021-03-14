class RankingsController < ApplicationController

  def user_favorite
  end

  def spot_favorite
    @all_ranks = Spot.create_spot_favorite_ranks
  end

end
