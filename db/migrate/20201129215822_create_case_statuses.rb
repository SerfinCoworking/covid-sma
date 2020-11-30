class CreateCaseStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :case_statuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
