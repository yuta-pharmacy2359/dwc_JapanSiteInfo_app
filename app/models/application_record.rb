class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  #性別選択
  enum sex: { 男性: 0, 女性: 1 }

  #都道府県選択
  enum prefecture: {
    北海道: 1, 青森県: 2, 岩手県: 3, 宮城県: 4, 秋田県: 5, 山形県: 6, 福島県: 7,
    茨城県: 8, 栃木県: 9, 群馬県: 10, 埼玉県: 11, 千葉県: 12, 東京都: 13, 神奈川県: 14,
    新潟県: 15, 富山県: 16, 石川県: 17, 福井県: 18, 山梨県: 19, 長野県: 20,
    岐阜県: 21, 静岡県: 22, 愛知県: 23, 三重県: 24,
    滋賀県: 25, 京都府: 26, 大阪府: 27, 兵庫県: 28, 奈良県: 29, 和歌山県: 30,
    鳥取県: 31, 島根県: 32, 岡山県: 33, 広島県: 34, 山口県: 35,
    徳島県: 36, 香川県: 37, 愛媛県: 38, 高知県: 39,
    福岡県: 40, 佐賀県: 41, 長崎県: 42, 熊本県: 43, 大分県: 44, 宮崎県: 45, 鹿児島県: 46,
    沖縄県: 47,
  }

  #いいね数ソート(SQL学習のため記述)
  ransacker :favorites_count do
    query = <<-SQL
      (SELECT COUNT(favorites.spot_id) as favorites_count
        FROM favorites
        WHERE favorites.spot_id = spots.id
        GROUP BY favorites.spot_id)
    SQL
    Arel.sql(query)
  end

  #スポット評価平均ソート(SQL学習のため記述)
  ransacker :rate_average do
    query = <<-SQL
      (SELECT AVG(spots.rate) as rate_average
        FROM keyword_relationships, spots
        WHERE keywords.id = keyword_relationships.keyword_id
        AND spots.id = keyword_relationships.spot_id
        GROUP BY keyword_relationships.keyword_id)
    SQL
    Arel.sql(query)
  end
end
