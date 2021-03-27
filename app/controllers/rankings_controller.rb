class RankingsController < ApplicationController
  before_action :authenticate_user!, { only: [:user_favorite, :spot_favorite] }

  def user_favorite
    @all_ranks = Spot.joins(:favorites).group("spots.user_id").count("favorites.id")
  end

  def spot_favorite
    @all_ranks = Spot.includes(:user, :favorites).create_spot_favorite_ranks
  end

end
