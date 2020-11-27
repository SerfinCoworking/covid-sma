class AddAssignedEstablishmentToPatients < ActiveRecord::Migration[5.2]
  def change
    add_column :patients, :assigned_establishment_id, :integer, default: 0
  end
end
