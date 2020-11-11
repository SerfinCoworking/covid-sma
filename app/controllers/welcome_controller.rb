class WelcomeController < ApplicationController

  def index
    if current_user.sector.present?      
    else
    end
  end
end
