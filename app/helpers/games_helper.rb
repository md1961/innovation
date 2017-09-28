module GamesHelper

  def age_conquests(player)
    player.conquests_for(@game).find_all(&:age?)
      .map(&:age).map(&:level).join(' ')
  end

  def category_conquests(player)
    player.conquests_for(@game).find_all(&:category?)
      .map(&:category).map(&:name).map(&:first).join(' ')
  end

  def action_options_display(action_options)
    return nil unless action_options
    action_options.split(/\s+/).map { |option|
      if option =~ /(\d+)\)\z/
        weight = Integer(Regexp.last_match(1))
        if weight >= 200
          "<b>#{option}</b>"
        elsif weight.zero?
          "<strike>#{option}</strike>"
        else
          option
        end
      else
        option
      end
    }.join(' ').html_safe
  end
end
