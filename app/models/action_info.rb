class ActionInfo
  attr_writer :is_executing, :h_action_targets

  def executing?
    @is_executing
  end

  def target_in_use?(target)
    return false unless @h_action_targets
    @h_action_targets[target.class.name]&.include?(target.id)
  end
end
