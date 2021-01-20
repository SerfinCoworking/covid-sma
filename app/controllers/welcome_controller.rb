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
      #     chart_data = Modality.joins(:exam)
  #                    .where(exams: {from_date: (now - 1.year)..now}).map {|m|
  #       {name: m.name, data: {m.exam.from_date => m.total}}}

  #     @exams = chart_data.group_by {|h| h[:name]}
  #                 .map {|k, v| {name: k, data: v.map {|h| h[:data]}.reduce(&:merge)}}

  #     chart_data = CaseCountPerDay.group_by_day(:created_at, range: 2.weeks.ago.midnight..Date.today, format: "%a %d/%m").map {|m| {name: m.name, data: {m.exam.from_date => m.total}}}

  #  @exams = chart_data.group_by {|h| h[:name]}
  #              .map {|k, v| {name: k, data: v.map {|h| h[:data]}.reduce(&:merge)}}
    else
      @permission_request = PermissionRequest.new
    end
  end
end
