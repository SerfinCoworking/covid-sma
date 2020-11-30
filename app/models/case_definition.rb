class CaseDefinition < ApplicationRecord
  enum case_type: { sospechoso: 0, pendiente: 1, positivo: 2, negativo: 3, recuperado: 4, fallecido: 5 }
  belongs_to :case_status, optional: true
  belongs_to :diagnostic_method, optional: true
  belongs_to :special_device
  has_one :epidemic_sheet

  delegate :name, :badge, to: :case_status, prefix: :case_status

  validates_presence_of :diagnostic_method_id, unless: Proc.new { |case_d| case_d.sospechoso? }
  validates_presence_of :special_device, :case_status_id
end
