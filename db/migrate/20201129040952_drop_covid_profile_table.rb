class DropCovidProfileTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :covid_profiles
    drop_table :covid_profile_movements
  end
end
