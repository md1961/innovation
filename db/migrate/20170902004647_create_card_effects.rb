class CreateCardEffects < ActiveRecord::Migration

  def change
    create_table :card_effects do |t|
      t.references :card       , index: true, foreign_key: true
      t.references :resource   , index: true, foreign_key: true
      t.boolean    :is_for_all , null: false
      t.string     :content    , null: false
      t.string     :content_eng
    end
  end
end
