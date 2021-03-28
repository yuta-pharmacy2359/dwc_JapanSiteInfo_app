class RankingsController < ApplicationController
  before_action :authenticate_user!, { only: [:user_favorite, :spot_favorite] }

  def user_favorite
    @all_ranks = Spot.joins(:favorites).group("spots.user_id").count("favorites.id")
    @spots_count = User.joins(:spots).group("user_id").count("spots.id")
  end

  def spot_favorite
    @all_ranks = Spot.includes(:user, :favorites).create_spot_favorite_ranks
  end
end
