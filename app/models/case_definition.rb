class CaseDefinition < ApplicationRecord
  belongs_to :case_status
  belongs_to :diagnostic_method, optional: true
  belongs_to :special_device
  has_one :epidemic_sheet

  delegate :name, :badge, to: :case_status, prefix: :case_status
  delegate :needs_diagnostic?, to: :case_status

  validates_presence_of :special_device, :case_status_id
  validates_presence_of :diagnostic_method_id, :special_device, if: Proc.new { |case_d| case_d.case_status.needs_diagnostic? }

  after_save :record_case_evolution, if: :saved_changes?

  def record_case_evolution
    CaseEvolution.create!(
      patient: self.epidemic_sheet.patient,
      epidemic_sheet: self.epidemic_sheet,
      case_status: self.case_status,
      diagnostic_method: self.diagnostic_method,
      special_device: self.special_device
    )
  end

  def needs_fis?
    if self.special_device.name != "Corte transversal"
      self.case_status.needs_fis?
    else
      return false
    end
  end

  scope :updated_since_date, lambda { |a_date|
    where('case_definitions.updated_at >= ?', a_date)
  }

  scope :updated_to_date, lambda { |a_date|
    where('case_definitions.updated_at <= ?', a_date)
  }

  def self.total_new_recovered
    recovered_status = CaseStatus.find_by_name('Recuperado')
    cases = CaseDefinition.updated_since_date(Date.yesterday.beginning_of_day).updated_to_date(Date.today.end_of_day)
    return cases.where(case_status_id: recovered_status.id).count
  end

  def self.total_new_negatives
    negative_status = CaseStatus.find_by_name('Negativo')
    cases = CaseDefinition.updated_since_date(Date.yesterday.beginning_of_day).updated_to_date(Date.today.end_of_day)
    return cases.where(case_status_id: negative_status.id).count
  end
end
