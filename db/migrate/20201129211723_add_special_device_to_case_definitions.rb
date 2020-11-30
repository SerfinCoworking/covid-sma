class AddSpecialDeviceToCaseDefinitions < ActiveRecord::Migration[5.2]
  def change
    add_reference :case_definitions, :special_device, index: true, default: 1
  end
end
