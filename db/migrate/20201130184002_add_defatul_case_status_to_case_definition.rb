class AddDefatulCaseStatusToCaseDefinition < ActiveRecord::Migration[5.2]
  def change
    change_column_default :case_definitions, :case_status_id, 1
  end
end
