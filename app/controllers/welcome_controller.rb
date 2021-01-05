class WelcomeController < ApplicationController

  def index
    if current_user.sector.present?
      _helper = ActiveSupport::NumberHelper
      _epidemic_sheets_today = EpidemicSheet.current_day
      _epidemic_sheets_month = EpidemicSheet.current_month
      @epidemic_sheets = EpidemicSheet.all
      @case_count_per_day = CaseCountPerDay.all
      @count_epidemic_sheets_today = _epidemic_sheets_today.count
      @count_epidemic_sheets_month = _epidemic_sheets_month.count
      @last_epidemic_sheets = @epidemic_sheets.order(created_at: :desc).limit(5)
    else
      @permission_request = PermissionRequest.new
    end
  end
end
