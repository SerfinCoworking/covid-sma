class CreateEpidemicSheets < ActiveRecord::Migration[5.2]
  def change
    create_table :epidemic_sheets do |t|
      t.references :patient, index: true
      t.references :case_definition, index: true
      t.references :created_by, index: true
      t.references :establishment, index: true
      t.date :init_symptom_date
      t.integer :epidemic_week
      t.boolean :presents_sumptoms
      t.text :symptoms_observations
      t.boolean :previous_symptoms
      t.text :prev_symptoms_observations
      t.integer :clinic_location, default: 0

      t.timestamps
    end
  end
end
