class Spot < ApplicationRecord

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :keyword_relationships, dependent: :destroy
  has_many :keywords, through: :keyword_relationships

  attachment :spot_image1
  attachment :spot_image2
  attachment :spot_image3

  def visited_day_is_valid?
    errors.add(:visited_day, "が無効な日付です") if visited_day.present? && visited_day > Date.today
  end

  def favorited_by?(user)
    favorites.where(user_id: user.id).exists?
  end

  def save_keyword(sent_keywords)
    current_keywords = self.keywords.pluck(:keyword) unless self.keywords.nil?
    old_keywords = current_keywords - sent_keywords
    new_keywords = sent_keywords - current_keywords

    old_keywords.each do |old|
      self.keywords.delete Keyword.find_by(keyword: old)
    end

    new_keywords.each do |new|
      new_spot_keyword = Keyword.find_or_create_by(keyword: new)
      self.keywords << new_spot_keyword
    end
  end

  validates :title, presence: true
  validate :visited_day_is_valid?
  validates :rate, numericality: {
    less_than_or_equal_to: 5,
  }

  private

  ransacker :favotites_count do
    query = <<-SQL
      (SELECT COUNT (favorites.spot_id)
        FROM favorites
        WHERE favorites.spot_id = spots.id
        GROUP BY favorites.spot_id)
    SQL
    Arel.sql(query)
  end
end
