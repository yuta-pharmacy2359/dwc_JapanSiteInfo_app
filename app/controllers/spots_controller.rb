class SpotsController < ApplicationController
  before_action :authenticate_user!, { only: [:new, :create] }
  before_action :baria_user, { only: [:edit, :update, :destroy] }

  def new
    @spot = Spot.new
  end

  def create
    @spot = Spot.new(spot_params)
    @spot.user_id = current_user.id
    @keyword_list = params[:spot][:keyword].split(nil)
    if @spot.save
      @spot.save_keyword(@keyword_list)
      flash[:notice] = "スポットを投稿しました"
      redirect_to spot_path(@spot.id)
    else
      render :new
    end
  end

  def show
    @spot = Spot.includes(:comments, :keywords).find(params[:id])
    @user = @spot.user
    @spot_keywords = @spot.keywords
    @comments = @spot.comments.includes(:user)
    @comment = Comment.new
    @cookies = cookies[:favorite_spot_id]
  end

  def index
    @q = Spot.ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    @spots = @q.result.page(params[:page]).includes(:favorites)
    @cookies = cookies[:favorite_spot_id]
  end

  def edit
    @spot = Spot.find(params[:id])
    @keyword_list = @spot.keywords.pluck(:keyword).join(nil)
  end

  def update
    @spot = Spot.find(params[:id])
    @keyword_list = params[:spot][:keyword].split(nil)
    if @spot.update(spot_params)
      @spot.save_keyword(@keyword_list)
      flash[:notice] = "スポットを更新しました"
      redirect_to spot_path(@spot.id)
    else
      render :edit
    end
  end

  def destroy
    @spot = Spot.find(params[:id])
    @spot.destroy
    flash[:notice] = "スポットを削除しました"
    redirect_to user_path(current_user)
  end

  private

  def spot_params
    params.require(:spot).permit(:title, :prefecture, :city, :visited_day, :rate, :spot_image1, :spot_image2, :spot_image3, :content)
  end

  def baria_user
    if current_user.nil? || Spot.find(params[:id]).user.id.to_i != current_user.id
      flash[:alert] = "権限がありません"
      redirect_to top_path
    end
  end

end
