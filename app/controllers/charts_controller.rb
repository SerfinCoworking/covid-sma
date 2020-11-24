class ChartsController < ApplicationController
  def by_month_epidemic_sheets
    render json: EpidemicSheet.group_by_month_of_year(:created_at).count.map{ |k, v| [I18n.t("date.month_names")[k], v]}
  end

  def by_month_covid_profiles
    render json: ExternalOrder.applicant(current_user.sector).group_by_month_of_year(:requested_date).count.map{ |k, v| [I18n.t("date.month_names")[k], v]}
  end

  def by_month_provider_external_orders
    render json: ExternalOrder.provider(current_user.sector)
      .group_by_month_of_year(:requested_date, range: 1.year.ago..Time.new)
      .count
      .map{ |k, v| [I18n.t("date.month_names")[k], v]}
  end

  def by_laboratory_lots
    render json: 
      SupplyLot.joins(:laboratory)
        .group('laboratories.name')
        .order('COUNT(laboratories.id) DESC')
        .count
        .first(8)
  end

  def by_status_current_sector_supply_lots
    render json: SectorSupplyLot.lots_for_sector(current_user.sector).group(:status).count.transform_keys { |key| key.split('_').map(&:capitalize).join(' ') }
  end

  def by_order_type_external_orders
    render json: ExternalOrder.orders_to_sector(current_user.sector).group(:order_type).count.map {|type| [type.first.humanize, type.second] }
  end
end
