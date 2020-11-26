class CreateSheetPreviousSymptoms < ActiveRecord::Migration[5.2]
  def change
    create_table :sheet_previous_symptoms do |t|
      t.references :epidemic_sheet, index: true
      t.references :previous_symptom, index: true
      t.timestamps
    end
  end
end
