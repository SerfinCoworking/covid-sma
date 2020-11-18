class CreateCurrentAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :current_addresses do |t|
      t.string :neighborhood
      t.string :street
      t.string :street_number

      t.timestamps
    end
    add_reference :patients, :current_address, foreign_key: true
  end
end
