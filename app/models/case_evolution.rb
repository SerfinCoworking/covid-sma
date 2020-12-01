class CaseEvolution < ApplicationRecord
  belongs_to :case_status
  belongs_to :diagnostic_method
  belongs_to :epidemic_sheet
  belongs_to :patient
  belongs_to :special_device

  validates_presence_of :case_status, :diagnostic_method, 
    :epidemic_sheet, :patient, :special_device

  delegate :name, :badge, to: :case_status, prefix: true

end
