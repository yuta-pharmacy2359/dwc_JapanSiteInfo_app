class Keyword < ApplicationRecord

  has_many :keyword_relationships, dependent: :destroy, foreign_key: 'keyword_id'
  has_many :spots, through: :keyword_relationships

end
