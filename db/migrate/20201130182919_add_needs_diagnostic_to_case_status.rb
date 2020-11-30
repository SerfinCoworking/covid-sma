class AddNeedsDiagnosticToCaseStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :case_statuses, :needs_diagnostic, :boolean, default: false
  end
end
