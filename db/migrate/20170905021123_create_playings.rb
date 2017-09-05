class CreatePlayings < ActiveRecord::Migration

  def change
    create_table :playings do |t|
      t.references :game    , index: true, foreign_key: true
      t.references :player  , index: true, foreign_key: true
      t.integer    :ordering, null: false
    end
  end
end
