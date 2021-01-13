class AddCloseContactsCountToEpidemicSheets < ActiveRecord::Migration[5.2]
  def change
    add_column :epidemic_sheets, :close_contacts_count, :integer
  end
end
