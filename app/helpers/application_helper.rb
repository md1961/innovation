module ApplicationHelper

  def in_use?(target)
    return false unless @h_action_targets.is_a?(Hash)
    @h_action_targets[target.class.name]&.include?(target.id)
  end
end
