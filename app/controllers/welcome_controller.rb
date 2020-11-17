class WelcomeController < ApplicationController

  def index
    if current_user.sector.present?
    else
      @permission_request = PermissionRequest.new
    end
  end
end
