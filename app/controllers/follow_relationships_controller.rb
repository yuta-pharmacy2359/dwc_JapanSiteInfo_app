class FollowRelationshipsController < ApplicationController
  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
  end

  def destroy
    @user = FollowRelationship.find(params[:id]).followed
    current_user.unfollow(@user)
  end
end
