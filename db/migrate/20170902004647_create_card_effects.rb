class CreateCardEffects < ActiveRecord::Migration

  def change
    create_table :card_effects do |t|
      t.references :card       , index: true, foreign_key: true
      t.references :resource   , index: true, foreign_key: true
      t.string     :content    , null: false
      t.string     :content_eng, null: false
    end
  end
end