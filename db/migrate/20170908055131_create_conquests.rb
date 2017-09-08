class CreateConquests < ActiveRecord::Migration

  def change
    create_table :conquests do |t|
      t.string     :type    , null: false
      t.references :game    , index: true, foreign_key: true
      t.references :player  , index: true, foreign_key: true
      t.references :age     , index: true, foreign_key: true
      t.references :category, index: true, foreign_key: true
    end
  end
end
