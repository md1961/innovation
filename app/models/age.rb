class Age < ActiveRecord::Base

  def next
    Age.find_by(level: level + 1)
  end

  def eql?(other)
    other.is_a?(self.class) && id == other.id
  end

  def hash
    id.hash
  end

  def to_s
    "#{level} #{name}"
  end
end
