class CreateSpots < ActiveRecord::Migration[5.2]
  def change
    create_table :spots do |t|
      t.integer :user_id
      t.string :title
      t.integer :prefecture
      t.string :city
      t.date :visited_day
      t.integer :rate
      t.string :spot_image1_id
      t.string :spot_image2_id
      t.string :spot_image3_id
      t.text :content

      t.timestamps
    end
  end
end
