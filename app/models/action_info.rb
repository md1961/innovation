class ActionInfo
  attr_writer :is_executing, :h_action_targets
  attr_accessor :action_options, :action_message

  def initialize(h_attrs = {})
    (h_attrs || {}).each do |name, value|
      instance_variable_set("@#{name}", value)
    end
    @h_action_targets = {} unless @h_action_targets
  end

  def executing?
    @is_executing
  end

  def action_targets=(targets)
    @h_action_targets = Array(targets).each_with_object(Hash.new { |h, k| h[k] = [] }) { |target, h|
      h[target.class.name] << target.id
    }
  end

  def target_in_use?(target)
    @h_action_targets[target.class.name]&.include?(target.id)
  end

  def target_cards
    @h_action_targets['Card']&.map { |id| Card.find(id) } || []
  end

  def dup_cleared(*attr_names)
    dup.tap { |dup|
      attr_names.each do |name|
        name = :h_action_targets if name == :action_targets
        dup.instance_variable_set("@#{name}", nil)
      end
    }
  end
end
