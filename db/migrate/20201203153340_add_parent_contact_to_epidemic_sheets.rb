class AddParentContactToEpidemicSheets < ActiveRecord::Migration[5.2]
  def change
    add_reference :epidemic_sheets, :parent_contact, index: true
  end
end
