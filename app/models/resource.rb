class Resource < ActiveRecord::Base
  belongs_to :color

  def eql?(other)
    name = other.name
  end

  def hash
    name.hash
  end

  def to_s
    name.first
  end
end
