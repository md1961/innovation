class CreatePlayers < ActiveRecord::Migration

  def change
    create_table :players do |t|
      t.string  :name       , null: false
      t.boolean :is_computer, null: false, default: false
    end
  end
end
