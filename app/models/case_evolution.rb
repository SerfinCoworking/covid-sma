class CaseEvolution < ApplicationRecord
  
  # Relationships
  belongs_to :case_status
  belongs_to :diagnostic_method
  belongs_to :epidemic_sheet
  belongs_to :patient
  belongs_to :special_device
  has_one :establishment, through: :epidemic_sheet

  # Validations
  validates_presence_of :case_status, :epidemic_sheet, :patient      
  validates_presence_of :diagnostic_method_id, :special_device, if: Proc.new { |case_e| case_e.case_status.needs_diagnostic? }

  # Delegations
  delegate :name, :badge, to: :case_status, prefix: true

  # Callbacks
  after_create :update_sisa

  private

  def update_sisa
    epidemic_sheet.is_in_sisa = false if case_status_name == 'Positivo (reinfección)'
    epidemic_sheet.save!
  end
end
