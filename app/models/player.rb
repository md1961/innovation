class Player < ActiveRecord::Base
  has_many :playings
  has_one :hand

  after_create :prepare

  def to_s
    name
  end

  private

    def prepare
      create_hand!
    end
end
