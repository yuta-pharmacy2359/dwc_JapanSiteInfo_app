class UsersController < ApplicationController
  before_action :authenticate_user!, { only: [:index] }
  before_action :baria_user, { only: [:edit, :update] }

  def show
    @user = User.find(params[:id])
    @q = @user.spots.ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    @spots = @q.result.page(params[:page])
    @all_user_spots = @user.spots
    @all_user_favorites_count = 0
    @all_user_spots.each do |spot|
      @all_user_favorites_count += spot.favorites.count
    end
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
    render 'show_follow'
  end

  def followers
    @title = "フォロワー一覧"
    @user = User.find(params[:id])
    @users= @user.followers.page(params[:page]).reverse_order
    render 'show_follow'
  end

  private

  def user_params
    params.require(:user).permit(:fullname, :nickname, :email, :sex, :birthday, :prefecture, :city, :profile_image, :introduction)
  end

  def baria_user
    unless User.find(params[:id]).id.to_i == current_user.id
      flash[:alert] = "権限がありません"
      redirect_to top_path
    end
  end

end
