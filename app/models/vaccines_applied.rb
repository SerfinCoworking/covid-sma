class VaccinesApplied < ApplicationRecord
  belongs_to :vaccine
  has_many :vaccine_doses
  has_one :epidemic_sheet_id

  accepts_nested_attributes_for :vaccine_doses, 
                                :allow_destroy => true,
                                reject_if: proc { |attributes| attributes['date_applied'].blank? }
end
