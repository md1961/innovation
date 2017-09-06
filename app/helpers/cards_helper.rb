module CardsHelper

  def color_class(model, options = {})
    return '' unless model && (@uses_color || options[:force])
    model.color.name_eng
  end

  def card_effect_in_span(effect)
    content_tag :span do
      concat (
        content_tag :span, effect.resource, class: color_class(effect.resource)
      )
      concat "#{effect.is_for_all ? '+' : '>'} #{effect.content}"
    end
  end

  def card_effects_display(card)
    safe_join(card.effects.map { |e| card_effect_in_span(e) }, '<br>'.html_safe)
  end

  def card_resource_in_div(card, pos)
    model = card.resource_at(pos) || card.age.level
    color = model.is_a?(Integer) ? 'age' : color_class(model)
    content_tag :div, class: 'card_resource' do
      content_tag :span, model, class: color
    end
  end
end
