class AddClinicLocationToCovidProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :covid_profiles, :clinic_location, :integer, default: 0
  end
end
