class CreateSpecialDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :special_devices do |t|
      t.string :name

      t.timestamps
    end

    SpecialDevice.create(name: "No")
    SpecialDevice.create(name: "DetectAR")
    SpecialDevice.create(name: "Unidad centinela IRA")
    SpecialDevice.create(name: "Corte transversal")
  end
end
