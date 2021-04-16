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


      @efector_bubble_chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: "Cantidad de casos por definición y establecimiento en "+current_user.establishment_city.name)

        CaseStatus.find([2,3,4,5,11]).each do |status|
          @data = []
          current_user.establishment_city.establishments.each do |establishment|
            if establishment.assigned_epidemic_sheets.by_case_statuses(status.id).present?
              @data << { name: establishment.short_name, value: establishment.assigned_epidemic_sheets.by_case_statuses(status.id).count }
            end
          end
          f.series(
            name: status.name,
            data: @data
          )
        end
        f.colors(["#292b2c", "#d9534f", "#5bc0de", "#5cb85c", "#d9534f"])

        f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical')
        f.tooltip(
          useHTML: true,
          pointFormat: '<b>{point.name}:</b> {point.value}'
        )
        f.plot_options(packedbubble:{
          minSize: '20%',
          maxSize: '100%',
          zMin: 0,
          zMax: 1000,
          layoutAlgorithm: {
            gravitationalConstant: 0.05,
            splitSeries: true,
            seriesInteraction: false,
            dragBetweenSeries: true,
            parentNodeLimit: true
          },
          dataLabels: {
            enabled: true,
            format: '{point.name}',
            filter: {
                property: 'y',
                operator: '>',
                value: 1
            },
            style: {
                color: 'black',
                textOutline: 'none',
                fontWeight: 'normal'
            }
          }
        })
        f.chart(
          defaultSeriesType: "packedbubble",
          height: '80%'
        )
      end
    else
      @permission_request = PermissionRequest.new
    end
  end
end
