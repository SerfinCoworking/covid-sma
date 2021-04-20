class CreateVaccinesApplieds < ActiveRecord::Migration[5.2]
  def change
    create_table :vaccines_applieds do |t|
      t.references :vaccine, index: true
      t.timestamps
    end
  end
end
