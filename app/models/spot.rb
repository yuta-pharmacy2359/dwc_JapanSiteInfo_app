class Spot < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_users, through: :favorites, source: :user
  has_many :keyword_relationships, dependent: :destroy
  has_many :keywords, through: :keyword_relationships

  attachment :spot_image1
  attachment :spot_image2
  attachment :spot_image3

  def visited_day_is_valid?
    errors.add(:visited_day, "が無効な日付です") if visited_day.present? && visited_day > Date.today
  end

  def favorited_by?(user)
    favorites.find { |f| f.user_id == user.id }.present?
  end

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

  validates :title, presence: true, length: { maximum: 20 }
  validates :prefecture, presence: true
  validates :city, presence: true, length: { maximum: 15 }
  validate :visited_day_is_valid?
  validates :content, presence: true, length: { maximum: 300 }
end
