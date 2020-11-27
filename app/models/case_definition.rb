class CaseDefinition < ApplicationRecord
  enum case_type: { sospechoso: 0, pendiente: 1, positivo: 2, negativo: 3, recuperado: 4, fallecido: 5 }
  belongs_to :diagnostic_method, optional: true

  validates_presence_of :diagnostic_method_id, unless: Proc.new { |case_d| case_d.sospechoso? }
end
