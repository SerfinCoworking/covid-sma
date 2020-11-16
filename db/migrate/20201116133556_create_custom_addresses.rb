class CreateCustomAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_addresses do |t|
      t.string :postal_code
      t.text :line
      t.references :city, foreign_key: true
      t.references :country, index: true
      t.references :state, index: true
      t.string :neighborhood
      t.string :street
      t.string :street_number
      t.string :floor
      t.string :department

      t.timestamps
    end
    add_reference :patients, :custom_address, foreign_key: true
  end
end
