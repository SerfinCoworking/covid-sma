namespace :batch do
  desc 'Save in database the case count per day'
  task save_case_count_per_days: :environment do
    # Obtenemos todas las ciudades que poseen fichas epidemiológicas e iteramos
    City.includes(:epidemic_sheets).where.not(epidemic_sheets: {id: nil}).each do |city|
      # Iteramos por todos los estados posibles contabilizando las cantidades de fichas
      CaseStatus.find_each do |status|
        # Fichas epidemiológicas de la ciudad
        today_epidemic_sheets = EpidemicSheet
          .by_city(city)
          .joins(:case_definition)
          .where(case_definitions: { case_status_id: status.id })
          .to_date(Date.today.strftime("%d/%m/%y"))

        CaseCountPerDay.create(
          case_status_id: status.id,
          count: today_epidemic_sheets.count,
          city_id: city.id
        )
      end
    end
  end

  desc 'Update in database the positive cases that the FIS is graeater than 14 days'
  task update_restored_positive_cases: :environment do
    positive_status = CaseStatus.find_by_name('Positivo')
    positive_sheets = EpidemicSheet.ambulatorio.joins(:case_definition).where(case_definitions: { case_status_id: positive_status.id })

    positive_sheets.find_each do |sheet|
      if (Date.today - sheet.init_symptom_date).to_i > 14
        sheet.case_definition.case_status_id = CaseStatus.find_by_name('Recuperado').id
        sheet.save!
      end
    end
  end
end
