class AddOcuppationToPatients < ActiveRecord::Migration[5.2]
  def change
    add_reference :patients, :occupation, index: true
  end
end
