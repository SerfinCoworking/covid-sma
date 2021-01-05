class CountCasePerDaySinceMondayTwentyOne < ActiveRecord::Migration[5.2]
  def change
    CaseCountPerDay.destroy_all
    i = 0
    notification_date = Date.new(2020, 12, 21)
    while i < 15      
      CaseStatus.find_each do |status|
        today_epidemic_sheets = EpidemicSheet.joins(:case_definition)
          .where(case_definitions: { case_status_id: status.id })
          .since_date(notification_date.beginning_of_day)
          .to_date(notification_date.end_of_day)
        
        CaseCountPerDay.create(
          case_status_id: status.id,
          count: today_epidemic_sheets.count,
          created_at: notification_date
        )
      end
      notification_date = notification_date + 1.days
      i += 1
    end
  end
end
