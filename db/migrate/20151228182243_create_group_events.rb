class CreateGroupEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :group_events do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.text :description
      t.string :location
      t.integer :state, default: 0
      t.datetime :deleted_at, default: nil

      t.timestamps
    end
    add_index :group_events, :state
    add_index :group_events, :deleted_at
  end
end
