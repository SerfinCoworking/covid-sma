class CreateSheetComments < ActiveRecord::Migration[5.2]
  def change
    create_table :sheet_comments do |t|
      t.references :epidemic_sheet, index: true
      t.references :user, index: true
      t.text :text

      t.timestamps
    end
  end
end
