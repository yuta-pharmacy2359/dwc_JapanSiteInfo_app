module NotificationsHelper
  def notification_form(notification)
    @server = notification.server
    @comment = nil
    @server_comment = notification.comment_id
    case notification.kind
      when 'follow' then
        tag.a(notification.server.nickname, href: user_path(@server)) + "があなたをフォローしました"
      when 'favorite' then
        tag.a(notification.server.nickname, href: user_path(@server)) + "が" + tag.a("あなたの投稿", href: spot_path(notification.spot_id)) + "にいいねしました"
      when 'comment' then
        tag.a(@server.nickname, href: user_path(@server)) + "が" + tag.a("あなたの投稿", href: spot_path(notification.spot_id)) + "にコメントしました"
    end
  end

  def uncheck_notifications
    @notifications = current_user.passive_notifications.where(check: false)
  end

end
