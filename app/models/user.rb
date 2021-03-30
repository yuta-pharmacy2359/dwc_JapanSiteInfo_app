class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

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
    day1 = birthday.strftime("%Y%m%d").to_i
    day2 = Date.today.strftime("%Y%m%d").to_i
    (day2 - day1) / 10000
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

  def spot_present?(user)
    spots.find { |f| f.user_id == user.id }.present?
  end

  def remember_me
    true
  end

  validates :fullname, presence: true, length: { maximum: 20 }
  validates :nickname, { presence: true, uniqueness: true, length: { maximum: 20 } }
  validates :sex, presence: true
  validate :birthday_is_valid?
  validates :prefecture, presence: true
  validates :city, presence: true, length: { maximum: 15 }
  validates :introduction, length: { maximum: 50 }
end
