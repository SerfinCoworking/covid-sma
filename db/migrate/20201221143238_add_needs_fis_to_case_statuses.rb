class AddNeedsFisToCaseStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :case_statuses, :needs_fis, :boolean, :default => false
  end
end
