class CreateSheetSymptoms < ActiveRecord::Migration[5.2]
  def change
    create_table :sheet_symptoms do |t|
      t.references :epidemic_sheet, index: true
      t.references :symptom, index: true
      t.timestamps
    end
  end
end
