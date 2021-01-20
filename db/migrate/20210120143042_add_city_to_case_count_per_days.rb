class AddCityToCaseCountPerDays < ActiveRecord::Migration[5.2]
  def change
    add_reference :case_count_per_days, :city, index: true
    CaseCountPerDay.find_each do |casecount|
      casecount.city = City.find(1)
      casecount.save!
    end
  end
end
