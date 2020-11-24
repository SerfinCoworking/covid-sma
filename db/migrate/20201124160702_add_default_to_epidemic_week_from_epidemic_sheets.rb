class AddDefaultToEpidemicWeekFromEpidemicSheets < ActiveRecord::Migration[5.2]
  def change
    change_column :epidemic_sheets, :epidemic_week, :integer, default: 0
  end
end
