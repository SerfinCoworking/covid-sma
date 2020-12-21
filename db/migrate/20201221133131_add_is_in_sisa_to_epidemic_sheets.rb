class AddIsInSisaToEpidemicSheets < ActiveRecord::Migration[5.2]
  def change
    add_column :epidemic_sheets, :is_in_sisa, :boolean, default: false
  end
end
