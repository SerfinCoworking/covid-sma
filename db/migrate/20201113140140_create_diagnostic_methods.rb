class CreateDiagnosticMethods < ActiveRecord::Migration[5.2]
  def change
    create_table :diagnostic_methods do |t|
      t.string :name

      t.timestamps
    end
  end
end
