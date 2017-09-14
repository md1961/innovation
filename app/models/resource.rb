class Resource < ActiveRecord::Base
  extend NameEngFindable

  belongs_to :color

  default_scope { order(:id) }

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
