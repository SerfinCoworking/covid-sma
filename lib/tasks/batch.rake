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
end
