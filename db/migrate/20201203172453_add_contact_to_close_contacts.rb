class AddContactToCloseContacts < ActiveRecord::Migration[5.2]
  def change
    add_reference :close_contacts, :contact, index: true
  end
end
