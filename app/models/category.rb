class Category < ActiveRecord::Base
  default_scope { order(:id) }

  def eql?(other)
    other.is_a?(self.class) && id == other.id
  end

  def hash
    id.hash
  end
end
