class FollowRelationshipsController < ApplicationController

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    redirect_back(fallback_location: top_path)
  end

  def destroy
    @user = FollowRelationship.find(params[:id]).followed
    current_user.unfollow(@user)
    redirect_back(fallback_location: top_path)
  end

end
