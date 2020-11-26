class RenamePreviousSymptomColumnOnEpidemicSheet < ActiveRecord::Migration[5.2]
  def change
    rename_column :epidemic_sheets, :previous_symptoms, :present_previous_symptoms
  end
end
