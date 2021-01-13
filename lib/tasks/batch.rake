namespace :batch do
  desc 'Save in database the case count per day'
  task save_case_count_per_days: :environment do
    CaseStatus.find_each do |status|

      today_epidemic_sheets = EpidemicSheet.joins(:case_definition)
        .where(case_definitions: { case_status_id: status.id })
        .to_date(Date.today.end_of_day)

      CaseCountPerDay.create(
        case_status_id: status.id,
        count: today_epidemic_sheets.count
      )
    end
  end

  desc 'Update in database the positive cases that the FIS is graeater than 14 days'
  task update_restored_positive_cases: :environment do
    positive_status = CaseStatus.find_by_name('Positivo')
    positive_sheets = EpidemicSheet.joins(:case_definition).where(case_definitions: { case_status_id: positive_status.id })

    positive_sheets.find_each do |sheet|
      if (Date.today - sheet.init_symptom_date).to_i > 14
        sheet.case_definition.case_status_id = CaseStatus.find_by_name('Recuperado').id
        sheet.save!
      end
    end
  end
end
