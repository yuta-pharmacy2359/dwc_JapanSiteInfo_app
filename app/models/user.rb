class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :spots, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy

  attachment :profile_image

  def age
    day1 = self.birthday.strftime("%Y%m%d").to_i
    day2 = Date.today.strftime("%Y%m%d").to_i
    return (day2 - day1) / 10000
  end

  def birthday_is_valid?
   errors.add(:birthday, "が無効な日付です") if birthday.nil? || birthday > Date.today
  end

  validates :fullname, presence: true
  validates :nickname, presence: true
  validates :sex, presence: true
  validate :birthday_is_valid?
  validates :prefecture, presence: true
  validates :city, presence: true

end
