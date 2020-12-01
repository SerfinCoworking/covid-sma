class CreateCaseDefinitions < ActiveRecord::Migration[5.2]
  def change
    create_table :case_definitions do |t|
      t.references :diagnostic_method, index: true
      t.references :case_status, index: true, default: 1
      
      t.timestamps
    end
  end
end
