class CreateKeywordRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :keyword_relationships do |t|
      t.integer :spot_id
      t.integer :keyword_id

      t.timestamps
    end
  end
end
