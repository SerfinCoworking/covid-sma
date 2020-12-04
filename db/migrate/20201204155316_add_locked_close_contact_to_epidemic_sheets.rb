class AddLockedCloseContactToEpidemicSheets < ActiveRecord::Migration[5.2]
  def change
    add_reference :epidemic_sheets, :locked_close_contact, index: true
  end
end
