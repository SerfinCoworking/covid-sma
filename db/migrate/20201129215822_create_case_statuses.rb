class CreateCaseStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :case_statuses do |t|
      t.string :name
      t.references :case_status, index: true, default: 1
      t.string :badge, default: 'secondary'
      t.boolean :needs_diagnostic, default: false

      t.timestamps
    end
  end
end
