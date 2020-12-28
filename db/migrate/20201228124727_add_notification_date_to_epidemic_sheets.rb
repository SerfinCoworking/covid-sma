class AddNotificationDateToEpidemicSheets < ActiveRecord::Migration[5.2]
  def change
    add_column :epidemic_sheets, :notification_date, :date

    EpidemicSheet.all.each do |epidemic_sheet|
      epidemic_sheet.update!(notification_date: epidemic_sheet.created_at)
    end
  end
end
