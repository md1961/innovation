class Stock < CardList
  after_create :prepare

  private

    def prepare
      Card.where(age: age).sort_by { rand }.each_with_index do |card, index|
        card_list_items.create!(card: card, ordering: index)
      end
    end
end
