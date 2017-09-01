class CreateColors < ActiveRecord::Migration

  def change
    create_table :colors do |t|
      t.string :name
      t.string :name_eng, null: false
      t.string :rgb     , null: false
    end
  end
end
