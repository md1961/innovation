class Age < ActiveRecord::Base

  def to_s
    "#{level} #{name}"
  end
end
