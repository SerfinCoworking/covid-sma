class CreateCaseCountPerDays < ActiveRecord::Migration[5.2]
  def change
    create_table :case_count_per_days do |t|
      t.references :case_status, index: true
      t.integer :count

      t.timestamps
    end
  end
end
