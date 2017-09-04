class Resource < ActiveRecord::Base
  belongs_to :color

  def to_s
    name.first
  end
end
