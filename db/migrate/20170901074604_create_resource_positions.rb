class CreateResourcePositions < ActiveRecord::Migration

  def change
    create_table :resource_positions do |t|
      t.string  :name
      t.string  :name_eng
      t.string  :abbr
      t.string  :abbr_eng
      t.boolean :is_left  , null: false
      t.boolean :is_right , null: false
      t.boolean :is_bottom, null: false
    end
  end
end
