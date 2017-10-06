module NameEngFindable

  def self.extended(model)
    model.pluck(:name_eng).each do |name|
      model.define_singleton_method(name.downcase) do
        var_name = "@#{name.downcase}"
        model.instance_variable_get(var_name) || \
          model.instance_variable_set(var_name, model.find_by(name_eng: name))
      end
    end
  end
end
