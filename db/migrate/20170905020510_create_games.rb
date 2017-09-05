class CreateGames < ActiveRecord::Migration

  def change
    create_table :games do |t|
      t.integer :num_players, null: false, default: 2
      t.string  :remark

      t.timestamps null: false
    end
  end
end
