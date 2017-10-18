class ActionInfo
  attr_writer :is_executing, :h_action_targets

  def executing?
    @is_executing
  end

  def h_action_targets
    @h_action_targets ||= {}
  end

  def target_in_use?(target)
    h_action_targets[target.class.name]&.include?(target.id)
  end

  def target_cards
    h_action_targets['Card']&.map { |id| Card.find(id) } || []
  end
end
