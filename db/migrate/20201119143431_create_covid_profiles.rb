class CreateCovidProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :covid_profiles do |t|
      t.references :epidemic_sheet, index: true
      t.references :patient, index: true
      t.date :init_symptom_date
      t.integer :status

      t.timestamps
    end
  end
end
