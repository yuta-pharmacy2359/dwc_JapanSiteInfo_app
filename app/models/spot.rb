class Spot < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_users, through: :favorites, source: :user
  has_many :keyword_relationships, dependent: :destroy
  has_many :keywords, through: :keyword_relationships
  has_many :notifications, dependent: :destroy

  attachment :spot_image1
  attachment :spot_image2
  attachment :spot_image3

  #来訪日のバリデーション
  def visited_day_is_valid?
    errors.add(:visited_day, "が無効な日付です") if visited_day.present? && visited_day > Date.today
  end

  #いいね済みかどうかの判断
  def favorited_by?(user)
    favorites.find { |f| f.user_id == user.id }.present?
  end

  #キーワードの保存
  def save_keyword(sent_keywords)
    current_keywords = keywords.pluck(:keyword) unless keywords.nil?
    old_keywords = current_keywords - sent_keywords
    new_keywords = sent_keywords - current_keywords

    old_keywords.each do |old|
      keywords.delete Keyword.find_by(keyword: old)
    end

    new_keywords.each do |new|
      new_spot_keyword = Keyword.find_or_create_by(keyword: new)
      keywords << new_spot_keyword
    end
  end

  #いいねの通知
  def create_notification_by(current_user)
    notification = current_user.active_notifications.new(spot_id: id, host_id: user_id, kind: "favorite")
    notification.save if notification.valid?
  end

  #コメントの通知
  def create_notification_comment!(current_user, comment_id)
    temp_ids = Comment.select(:user_id).where(spot_id: id).where.not(user_id: current_user.id).distinct
    temp_ids.each do |temp_id|
      save_notification_comment!(current_user, comment_id, temp_id['user_id'])
    end
    save_notification_comment!(current_user, comment_id, user_id) if temp_ids.blank?
  end

  #コメントの通知
  def save_notification_comment!(current_user, comment_id, host_id)
    notification = current_user.active_notifications.new(spot_id: id, comment_id: comment_id, host_id: host_id, kind: "comment")
    if notification.server_id == notification.host_id
      notification.check = true
    end
    notification.save if notification.valid?
  end

  #スポット別いいね数ランキングの集計
  def self.create_spot_favorite_ranks
    Spot.find(Favorite.group(:spot_id).order('count(spot_id) desc').pluck(:spot_id))
  end

  validates :title, presence: true, length: { maximum: 20 }
  validates :prefecture, presence: true
  validates :city, presence: true, length: { maximum: 15 }
  validate :visited_day_is_valid?
  validates :content, presence: true, length: { maximum: 300 }
end
