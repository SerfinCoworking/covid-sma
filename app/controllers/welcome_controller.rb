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
