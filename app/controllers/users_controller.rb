class UsersController < ApplicationController
  before_action :baria_user, { only: [:edit, :update] }

  def show
    @user= User.find(params[:id])
    @spots = @user.spots.page(params[:page]).reverse_order
  end

  def index
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
