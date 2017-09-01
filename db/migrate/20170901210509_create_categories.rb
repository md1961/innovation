class CreateCategories < ActiveRecord::Migration

  def change
    create_table :categories do |t|
      t.string :name         , null: false
      t.string :name_eng
      t.string :condition    , null: false
      t.string :condition_eng
      t.string :note         , null: false
      t.string :note_eng
    end
  end
end
