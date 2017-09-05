class CreateCardLists < ActiveRecord::Migration

  def change
    create_table :card_lists do |t|
      t.string     :type
      t.references :game  , index: true, foreign_key: true
      t.references :player, index: true, foreign_key: true
      t.references :age   , index: true, foreign_key: true
      t.references :color , index: true, foreign_key: true
    end
  end
end
