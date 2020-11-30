class CaseDefinition < ApplicationRecord
  belongs_to :case_status
  belongs_to :diagnostic_method, optional: true
  belongs_to :special_device
  has_one :epidemic_sheet

  delegate :name, :badge, to: :case_status, prefix: :case_status
  delegate :needs_diagnostic?, to: :case_status

  validates_presence_of :special_device, :case_status_id
  validates_presence_of :diagnostic_method_id, if: Proc.new { |case_d| case_d.case_status.needs_diagnostic? }
end
