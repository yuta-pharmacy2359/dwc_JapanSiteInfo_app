class AddColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sex, :integer
    add_column :users, :birthday, :integer
    add_column :users, :prefecture, :integer
    add_column :users, :city, :string
    add_column :users, :profile_image_id, :string
    add_column :users, :introduction, :string
  end
end
