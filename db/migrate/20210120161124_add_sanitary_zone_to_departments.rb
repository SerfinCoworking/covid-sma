class AddSanitaryZoneToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_reference :departments, :sanitary_zone, index: true
  end
end
