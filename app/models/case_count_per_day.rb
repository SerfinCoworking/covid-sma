class CaseCountPerDay < ApplicationRecord
  belongs_to :case_status
  belongs_to :city

  scope :by_city, lambda {|ids_ary| 
    where(case_count_per_days: { city_id: ids_ary}) 
  }
end
