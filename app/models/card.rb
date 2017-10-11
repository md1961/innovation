class Card < ActiveRecord::Base
  belongs_to :age
  belongs_to :color
  has_many :effects, -> { order(:id) }, class_name: 'CardEffect'
  has_many :card_resources
  has_many :resources, through: :card_resources
  has_many :card_list_items
  has_many :card_lists, through: :card_list_items

  POS_LT = 'LT'
  POS_LB = 'LB'
  POS_CB = 'CB'
  POS_RB = 'RB'

  POSITIONS = [POS_LT, POS_LB, POS_CB, POS_RB]
  POSITIONS_AT_BOTTOM = POSITIONS[1, 3]

  LEFT   = [POS_LT, POS_LB]
  RIGHT  = [POS_RB]
  BOTTOM = POSITIONS_AT_BOTTOM

  def resource_at(position_abbr)
    h_resources_by_position[position_abbr]
  end

  def resources_at(card_side_for_position_abbrs)
    return [] unless card_side_for_position_abbrs
    card_side_for_position_abbrs.map { |pos| resource_at(pos) }.compact
  end

  def has_resource?(resource_name)
    resources.include?(Resource.find_by(name: resource_name))
  end

  def card_list(game)
    card_lists.find_by(game: game)
  end

  def prev
    self.class.where('id < ?', id).order(id: :desc).first || self
  end

  def next
    self.class.where('id > ?', id).order(id: :asc ).first || self
  end

  def forcing?
    (effects.size == 1 && !effects.first.is_for_all) \
      || (effects.size == 2 && !effects.first.is_for_all && effects.last.conditional_on_effect_above?)
  end

  def offer(dest, game)
    card_list_from = card_list(game)
    player_from = card_list_from.player
    player_to = game.next_player(player_from)
    card_list_to = \
      if dest == Hand
        player_to.hand_for(game)
      elsif dest == Board
        player_to.boards_for(game).find_by(color: color)
      elsif dest == Influence
        player_to.influence_for(game)
      else
        raise "Illegal destination '#{dest}'"
      end
    self.class.transaction do
      card_list_from.remove(self)
      card_list_to.add(self)
    end
  end

  def eql?(other)
    other.is_a?(self.class) && id == other.id
  end

  def hash
    id.hash
  end

  def to_s
    "[#{age.level}]#{title}"
  end

  private

    def h_resources_by_position
      @h_resources_by_position ||= \
        card_resources.joins(:resource, :position)
        .select('resource_positions.abbr', 'resources.name_eng').map { |r|
          attrs = r.attributes
          [attrs['abbr'], Resource.send(attrs['name_eng'].downcase)]
        }.to_h
    end
end
