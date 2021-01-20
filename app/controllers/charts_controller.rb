class ChartsController < ApplicationController
  def by_month_epidemic_sheets
    render json: EpidemicSheet
      .by_city(current_user.establishment_city)
      .since_date(Date.today.beginning_of_year)
      .group_by_month_of_year("epidemic_sheets.created_at")
      .count.map{ |k, v| [I18n.t("date.month_names")[k], v]}
  end
end
