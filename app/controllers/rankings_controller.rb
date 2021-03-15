class RankingsController < ApplicationController

  def user_favorite
  end

  def spot_favorite
    @all_ranks = Kaminari.paginate_array(Spot.create_spot_favorite_ranks).page(params[:page])
  end

end
