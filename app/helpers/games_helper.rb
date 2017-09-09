module GamesHelper

  def age_conquests(player)
    player.conquests_for(@game).find_all(&:age?)
      .map(&:age).map(&:level).join(' ')
  end

  def category_conquests(player)
    player.conquests_for(@game).find_all(&:category?)
      .map(&:category).map(&:name).map(&:first).join(' ')
  end
end
