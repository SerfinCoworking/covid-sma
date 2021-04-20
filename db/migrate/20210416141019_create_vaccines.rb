class CreateVaccines < ActiveRecord::Migration[5.2]
  def change
    create_table :vaccines do |t|
      t.string :name
      t.timestamps
    end

    Vaccine.create(name: "Covishield")
    Vaccine.create(name: "Sputnik V")
    Vaccine.create(name: "Sinopharm")
  end
end
