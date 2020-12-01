class CreateCaseEvolutions < ActiveRecord::Migration[5.2]
  def change
    create_table :case_evolutions do |t|
      t.references :case_status, index: true
      t.references :diagnostic_method, index: true
      t.references :epidemic_sheet, index: true
      t.references :patient, index: true
      t.references :special_device, index: true

      t.timestamps
    end
  end
end
