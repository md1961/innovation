class Player < ActiveRecord::Base
  has_many :playings

  def to_s
    name
  end
end
