class CreateEpidemicSheetMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :epidemic_sheet_movements do |t|
      t.references :epidemic_sheet, index: true
      t.references :user, index: true
      t.references :sector, index: true
      t.string :action      

      t.timestamps
    end
  end
end
