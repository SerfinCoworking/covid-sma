class CreateSpecialDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :special_devices do |t|
      t.string :name

      t.timestamps
    end
  end
end
