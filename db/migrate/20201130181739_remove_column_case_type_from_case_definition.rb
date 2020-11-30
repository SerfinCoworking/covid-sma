class RemoveColumnCaseTypeFromCaseDefinition < ActiveRecord::Migration[5.2]
  def change
    remove_column :case_definitions, :case_type, :integer
  end
end
