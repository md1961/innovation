class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_color, :set_large

  protected

    def set_color
      set_param(:color, :uses_color)
    end

    def set_large
      set_param(:large, :uses_large)
    end

  private

    def set_param(param_name, var_name)
      case params[param_name]
      when 'true'
        session[var_name] = true
      when 'false'
        session[var_name] = false
      else
        session[var_name] = !session[var_name] if params[param_name]
      end
      instance_variable_set("@#{var_name}", session[var_name])
    end
end
