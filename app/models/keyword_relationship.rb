class KeywordRelationship < ApplicationRecord
  belongs_to :spot
  belongs_to :keyword

  validates :spot_id, presence: true
  validates :keyword_id, presence: true
end
