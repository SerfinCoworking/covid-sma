class CaseDefinition < ApplicationRecord
  belongs_to :case_status
  belongs_to :diagnostic_method, optional: true
  belongs_to :special_device
  has_one :epidemic_sheet
  has_one :establishment, through: :epidemic_sheet

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
    where('case_definitions.updated_at >= ?', DateTime.strptime(a_date, '%d/%m/%y').beginning_of_day)
  }

  scope :updated_to_date, lambda { |a_date|
    where('case_definitions.updated_at <= ?', DateTime.strptime(a_date, '%d/%m/%y').end_of_day)
  }

  scope :by_city, lambda {|ids_ary| 
    includes([:establishment]).where(establishments: {city_id: ids_ary} )
  }

  def self.total_new_recovered_to_city(a_city)
    return CaseDefinition
      .updated_since_date(Date.yesterday.strftime("%d/%m/%y"))
      .updated_to_date(Date.yesterday.strftime("%d/%m/%y"))
      .by_city(a_city)
      .where(case_status_id: CaseStatus.find_by_name('Recuperado').id)
      .count
  end

  def self.total_new_negatives_to_city(a_city)
    return CaseDefinition
      .updated_since_date(Date.yesterday.beginning_of_day)
      .updated_to_date(Date.yesterday.end_of_day)
      .by_city(a_city)
      .where(case_status_id: CaseStatus.find_by_name('Negativo').id)
      .count
  end

  def self.total_positives_to_city(a_city)
    status_ids = []
    status_ids << CaseStatus.find_by_name('Positivo (primoinfección)').id
    status_ids << CaseStatus.find_by_name('Positivo (reinfección)').id
    return CaseDefinition
      .by_city(a_city)
      .where(case_status_id: status_ids)   
      .count
  end
end
