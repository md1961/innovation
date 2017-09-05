class CreateGames < ActiveRecord::Migration

  def change
    create_table :games do |t|
      t.integer :num_players      , null: false, default: 2
      t.integer :current_player_id
      t.string  :remark

      t.timestamps null: false
    end
  end
end
