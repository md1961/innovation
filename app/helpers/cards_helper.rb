module CardsHelper

  def card_effect_display(effect)
    "[#{effect.resource}]#{effect.is_for_all ? '+' : '>'} #{effect.content}"
  end

  def card_effects_display(card)
    safe_join(card.effects.map { |e| card_effect_display(e) }, '<br>'.html_safe)
  end
end
