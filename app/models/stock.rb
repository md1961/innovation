class Stock < CardList
  belongs_to :age

  after_create :prepare

  def next_card
    cards.first
  end

  def draw
    raise "No card left in Stock [#{age.level}]" if empty?
    card = next_card
    card_list_items.first.destroy
    card
  end

  private

    def prepare
      Card.where(age: age).sort_by { rand }.each_with_index do |card, index|
        card_list_items.create!(card: card, ordering: index)
      end
    end
end
