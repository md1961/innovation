module CardsHelper

  def card_effect_display(effect)
    content_tag :span do
      concat '['
      concat (
        content_tag :span, effect.resource, class: effect.resource.color.name_eng
      )
      concat "]#{effect.is_for_all ? '+' : '>'} #{effect.content}"
    end
  end

  def card_effects_display(card)
    safe_join(card.effects.map { |e| card_effect_display(e) }, '<br>'.html_safe)
  end

  def card_resource_in_div(card, pos)
    value = card.resource_at(pos) || card.age.level
    color = value.is_a?(Integer) ? 'age' : value.color.name_eng
    content_tag :div, class: 'card_resource' do
      content_tag :span, value, class: color
    end
  end
end
