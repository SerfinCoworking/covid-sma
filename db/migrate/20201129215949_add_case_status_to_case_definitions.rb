class AddCaseStatusToCaseDefinitions < ActiveRecord::Migration[5.2]
  def change
    add_reference :case_definitions, :case_status, index: true
  end
end
