class CreateCloseContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :close_contacts do |t|
      t.references :epidemic_sheet, index: true
      t.references :patient, index: true
      t.references :contact_type, index: true
      t.string :full_name
      t.string :dni
      t.string :phone
      t.string :address
      t.date :last_contact_date

      t.timestamps
    end
  end
end
