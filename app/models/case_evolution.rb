class CaseEvolution < ApplicationRecord
  belongs_to :case_status
  belongs_to :diagnostic_method
  belongs_to :epidemic_sheet
  belongs_to :patient
  belongs_to :special_device
  has_one :establishment, through: :epidemic_sheet

  validates_presence_of :case_status, :epidemic_sheet, :patient      
  validates_presence_of :diagnostic_method_id, :special_device, if: Proc.new { |case_e| case_e.case_status.needs_diagnostic? }

  delegate :name, :badge, to: :case_status, prefix: true
end
