class CreateCaseDefinitions < ActiveRecord::Migration[5.2]
  def change
    create_table :case_definitions do |t|
      t.integer :case_type, default: 0
      t.references :diagnostic_method, index: true

      t.timestamps
    end
  end
end
