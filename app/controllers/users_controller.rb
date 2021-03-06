class UsersController < ApplicationController
  def show
    @user= User.find(params[:id])
    @spots = @user.spots
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

end
