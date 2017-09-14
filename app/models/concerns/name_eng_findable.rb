module NameEngFindable

  def self.extended(model)
    model.pluck(:name_eng).each do |name|
      model.define_singleton_method(name.downcase) do
        model.find_by(name_eng: name)
      end
    end
  end
end
