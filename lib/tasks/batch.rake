namespace :batch do
  desc 'Save in database the case count per day'
  task save_case_count_per_days: :environment do
    CaseStatus.find_each do |status|

      today_epidemic_sheets = status.epidemic_sheets.current_day

      CaseCountPerDay.create(
        case_status_id: status.id,
        count: today_epidemic_sheets.count
      )
    end
  end
end
