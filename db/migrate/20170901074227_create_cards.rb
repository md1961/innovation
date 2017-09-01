class CreateCards < ActiveRecord::Migration

  def change
    create_table :cards do |t|
      t.references :age       , index: true, foreign_key: true
      t.references :color     , index: true, foreign_key: true
      t.string     :title     , null: false
      t.string     :title_eng
      t.string     :effect    , null: false
      t.string     :effect_eng
      t.binary     :image

      t.timestamps null: false
    end
  end
end
