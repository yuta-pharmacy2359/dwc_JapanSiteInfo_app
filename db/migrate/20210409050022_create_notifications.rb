class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.integer :spot_id
      t.integer :server_id
      t.integer :host_id
      t.integer :comment_id
      t.string :kind
      t.boolean :check, default: false, null: false

      t.timestamps
    end
  end
end
