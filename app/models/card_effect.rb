class CardEffect < ActiveRecord::Base
  belongs_to :resource

  def conditional_on_effect_above?
    content.starts_with?('上記の優越型教義により')
  end
end
