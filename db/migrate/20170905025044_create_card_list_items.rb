class CreateCardListItems < ActiveRecord::Migration

  def change
    create_table :card_list_items do |t|
      t.references :card_list, index: true, foreign_key: true
      t.references :card     , index: true, foreign_key: true
      t.integer    :ordering
    end
  end
end
