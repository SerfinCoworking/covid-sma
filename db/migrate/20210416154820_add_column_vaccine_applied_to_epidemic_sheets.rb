class AddColumnVaccineAppliedToEpidemicSheets < ActiveRecord::Migration[5.2]
  def change
    add_reference :epidemic_sheets, :vaccines_applied, index: true
  end
end
