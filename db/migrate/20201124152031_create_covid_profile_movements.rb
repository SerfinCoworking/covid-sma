class CreateCovidProfileMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :covid_profile_movements do |t|
      t.references :covid_profile, index: true
      t.references :user, index: true
      t.references :sector, index: true
      t.string :action      
      t.timestamps
    end
  end
end
