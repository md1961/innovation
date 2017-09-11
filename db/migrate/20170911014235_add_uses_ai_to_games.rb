class AddUsesAiToGames < ActiveRecord::Migration

  def change
    add_column :games, :uses_ai, :boolean, null: false, default: true
  end
end
