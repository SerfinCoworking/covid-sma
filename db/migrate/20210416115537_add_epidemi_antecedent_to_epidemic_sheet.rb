class AddEpidemiAntecedentToEpidemicSheet < ActiveRecord::Migration[5.2]
  def change
    add_column :epidemic_sheets, :presents_epidemi_antecedents, :boolean
    add_column :epidemic_sheets, :epidemi_antecedent_observations, :text
  end
end
