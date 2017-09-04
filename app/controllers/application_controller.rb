class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_color

  protected

    def set_color
      case params[:color]
      when 'true'
        session[:uses_color] = true
      when 'false'
        session[:uses_color] = false
      end
      @uses_color = session[:uses_color]
    end
end
