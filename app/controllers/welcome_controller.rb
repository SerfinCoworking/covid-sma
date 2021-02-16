class WelcomeController < ApplicationController

  def index
    if current_user.sector.present?
      _helper = ActiveSupport::NumberHelper
      @epidemic_sheets = EpidemicSheet.by_city(current_user.establishment_city)
      _epidemic_sheets_month = @epidemic_sheets.current_month
      _epidemic_sheets_today = @epidemic_sheets.current_day
      @case_count_per_day = CaseCountPerDay.by_city(current_user.establishment_city)
      @count_epidemic_sheets_today = _epidemic_sheets_today.count
      @count_epidemic_sheets_month = _epidemic_sheets_month.count
      @last_epidemic_sheets = @epidemic_sheets.order(created_at: :desc).limit(5)
      
      @total_positives = CaseStatus.total_positives_to_city(current_user.establishment_city)
      @total_recovered = CaseStatus.total_recovered_to_city(current_user.establishment_city)
      @total_new_positives = EpidemicSheet.total_new_positives_to_city(current_user.establishment_city)
      @total_new_recovered = CaseDefinition.total_new_recovered_to_city(current_user.establishment_city)
      @total_new_negatives = CaseDefinition.total_new_negatives_to_city(current_user.establishment_city)
      @total_close_contacts = EpidemicSheet.total_close_contacts_to_city(current_user.establishment_city)
      @total_historical_positives = CaseDefinition.total_positives_to_city(current_user.establishment_city)
      @total_hospitalized = EpidemicSheet.total_hospitalized_to_city(current_user.establishment_city)
      @total_historical_deaths = CaseStatus.total_deaths_to_city(current_user.establishment_city)
    else
      @permission_request = PermissionRequest.new
    end
  end
end
