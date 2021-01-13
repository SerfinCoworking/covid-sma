class PopulateCloseContactsCount < ActiveRecord::Migration[5.2]
  def change
    EpidemicSheet.find_each do |sheet|
      EpidemicSheet.reset_counters(sheet.id, :close_contacts)
    end
  end
end
