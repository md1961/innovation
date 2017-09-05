class Stock < CardList
  belongs_to :age

  after_create :prepare

  def to_partial_path
    'games/stock'
  end

  private

    def prepare
      Card.where(age: age).sort_by { rand }.each_with_index do |card, index|
        card_list_items.create!(card: card, ordering: index)
      end
    end
end
