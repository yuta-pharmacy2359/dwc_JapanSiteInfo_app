class CommentsController < ApplicationController
  before_action :authenticate_user!, { only: [:create] }
  before_action :baria_user, { only: [:destroy] }

  def create
    @spot = Spot.find(params[:spot_id])
    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    @comment.spot_id = @spot.id
    if @comment.save
      flash.now[:success] = "コメントを送信しました"
    else
      flash.now[:danger] = "コメントを記入してください"
    end
  end

  def destroy
    @comment = Comment.find_by(id: params[:id], spot_id: params[:spot_id])
    @comment.destroy
    @spot = @comment.spot
    flash.now[:success] = "コメントを削除しました"
  end

  private

  def comment_params
    params.require(:comment).permit(:comment)
  end

  def baria_user
    if current_user.nil? || Comment.find(params[:id]).user.id.to_i != current_user.id
      flash[:alert] = "権限がありません"
      redirect_to spot_path(@spot)
    end
  end

end
