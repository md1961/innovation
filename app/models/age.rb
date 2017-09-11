class Age < ActiveRecord::Base

  def next
    Age.find_by(level: level + 1)
  end

  def to_s
    "#{level} #{name}"
  end
end
