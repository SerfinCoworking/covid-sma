class AddBadgeToCaseStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :case_statuses, :badge, :string, default: 'secondary'
  end
end
