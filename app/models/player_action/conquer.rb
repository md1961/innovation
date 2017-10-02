module PlayerAction

class Conquer < Base

  def self.add_options_to(chooser)
    game   = chooser.game
    player = chooser.player

    targets = Conquest.conquerable_targets(player, game)
    if targets.any? { |target| target.is_a?(Category) }
      targets.reject! { |target| target.is_a?(Age) }
    end
    target = targets.sample
    chooser.add(new(game, player, target)) if target
  end

  def initialize(game, player, target)
    super(game, player)
    @target = target
  end

  def perform
    @player.conquer(@target, @game)
  end

  def message_after
    "#{@player} conquered #{@target}"
  end

  def conquer_category?
    @target.is_a?(Category)
  end

  def to_s
    "Conq-#{@target}"
  end
end

end
