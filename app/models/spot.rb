class Spot < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  attachment :spot_image1
  attachment :spot_image2
  attachment :spot_image3

   def visited_day_is_valid?
     errors.add(:visited_day, "が無効な日付です") if visited_day.present? && visited_day > Date.today
   end

   validates :title, presence: true
   validate :visited_day_is_valid?
end
