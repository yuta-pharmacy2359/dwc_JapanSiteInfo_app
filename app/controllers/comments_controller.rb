class CommentsController < ApplicationController
  before_action :baria_user, { only: [:destroy] }

  def create
    @spot = Spot.find(params[:spot_id])
    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    @comment.spot_id = @spot.id
    @comment.save
    flash[:notice] = "コメントを送信しました"
    redirect_to spot_path(@spot)
  end

  def destroy
    @comment = Comment.find_by(id: params[:id], spot_id: params[:spot_id])
    @comment.destroy
    flash[:notice] = "コメントを削除しました"
    redirect_to spot_path(params[:spot_id])
  end

  private

  def comment_params
    params.require(:comment).permit(:comment)
  end

  def baria_user
    unless Comment.find(params[:id]).user.id.to_i == current_user.id
      flash[:alert] = "権限がありません"
      redirect_to spot_path(@spot)
    end
  end

end
