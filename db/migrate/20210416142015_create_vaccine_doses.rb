class CreateVaccineDoses < ActiveRecord::Migration[5.2]
  def change
    create_table :vaccine_doses do |t|
      t.string :name
      t.date :date_applied
      t.references :vaccines_applied, index: true
      t.timestamps
    end
  end
end
