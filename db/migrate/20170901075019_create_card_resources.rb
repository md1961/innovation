class CreateCardResources < ActiveRecord::Migration

  def change
    create_table :card_resources do |t|
      t.references :card             , index: true, foreign_key: true
      t.references :resource         , index: true, foreign_key: true
      t.references :resource_position, index: true, foreign_key: true
    end
  end
end
