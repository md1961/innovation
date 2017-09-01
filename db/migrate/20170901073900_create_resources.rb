class CreateResources < ActiveRecord::Migration

  def change
    create_table :resources do |t|
      t.string     :name    , null: false
      t.string     :name_eng
      t.references :color   , index: true, foreign_key: true
      t.binary     :image
    end
  end
end
