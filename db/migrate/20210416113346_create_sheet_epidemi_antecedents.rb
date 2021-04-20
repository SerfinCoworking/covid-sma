class CreateSheetEpidemiAntecedents < ActiveRecord::Migration[5.2]
  def change
    create_table :sheet_epidemi_antecedents do |t|
      t.references :epidemic_sheet, index: true
      t.references :epidemi_antecedent, index: true
      t.timestamps
    end
  end
end
