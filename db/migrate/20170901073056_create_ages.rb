class CreateAges < ActiveRecord::Migration

  def change
    create_table :ages do |t|
      t.integer :level   , null: false
      t.string  :name    , null: false
      t.string  :name_eng
    end
  end
end
