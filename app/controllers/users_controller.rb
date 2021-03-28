class UsersController < ApplicationController
  before_action :authenticate_user!, { only: [:show, :index, :following, :followers] }
  before_action :baria_user, { only: [:edit, :update] }

  def show
    @user = User.find(params[:id])
    @q = @user.spots.ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    @spots = @q.result.page(params[:page]).includes(:favorites)
    @user_all_spots = @user.spots
    fav_count = @user_all_spots.joins(:favorites).group("spots.user_id").count("favorites.id")
    @user_all_favorites_count = fav_count.present? ? fav_count.fetch(@user.id) : 0
    @cookies = cookies[:favorite_spot_id]
  end

  def index
    @q = User.ransack(params[:q])
    @users = @q.result(distinct: true).page(params[:page]).reverse_order
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:notice] = "プロフィールを更新しました"
      redirect_to user_path(@user.id)
    else
      render :edit
    end
  end

  def following
    @title = "フォロー一覧"
    @user = User.find(params[:id])
    @users = @user.following.page(params[:page]).reverse_order
    @following_count = User.joins(:following).group("follower_id").count("followed_id")
    @followers_count = User.joins(:followers).group("followed_id").count("follower_id")
    @user_spots_last_updated_at = Spot.group("user_id").order("spots.updated_at").pluck(:user_id, :updated_at).to_h
    render 'show_follow'
  end

  def followers
    @title = "フォロワー一覧"
    @user = User.find(params[:id])
    @users = @user.followers.page(params[:page]).reverse_order
    @following_count = User.joins(:following).group("follower_id").count("followed_id")
    @followers_count = User.joins(:followers).group("followed_id").count("follower_id")
    @user_spots_last_updated_at = Spot.group("user_id").order("spots.updated_at").pluck(:user_id, :updated_at).to_h
    render 'show_follow'
  end

  private

  def user_params
    params.require(:user).permit(:fullname, :nickname, :email, :sex, :birthday, :prefecture, :city, :profile_image, :introduction)
  end

  def baria_user
    if current_user.nil? || User.find(params[:id]).id.to_i != current_user.id
      flash[:alert] = "権限がありません"
      redirect_to top_path
    end
  end
end
