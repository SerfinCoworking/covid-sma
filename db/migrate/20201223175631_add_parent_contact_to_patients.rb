class AddParentContactToPatients < ActiveRecord::Migration[5.2]
  def change
    add_reference :patients, :parent_contact, index: true
  end
end
