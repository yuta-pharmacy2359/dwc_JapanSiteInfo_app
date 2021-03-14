class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :spots, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_spots, through: :favorites, source: :spot
  has_many :active_relationships, class_name: "FollowRelationship", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "FollowRelationship", foreign_key: "followed_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  attachment :profile_image

  def age
    day1 = self.birthday.strftime("%Y%m%d").to_i
    day2 = Date.today.strftime("%Y%m%d").to_i
    return (day2 - day1) / 10000
  end

  def birthday_is_valid?
   errors.add(:birthday, "が無効な日付です") if birthday.nil? || birthday > Date.today
  end

  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def favorite_amount(user)
    user_spots = User.spots
    favorites_count = 0
    user_spots.each do |spot|
      favorites_count += Spot.favorites.count
    end
    return favorites_count
  end

  validates :fullname, presence: true
  validates :nickname, presence: true
  validates :sex, presence: true
  validate :birthday_is_valid?
  validates :prefecture, presence: true
  validates :city, presence: true

end
