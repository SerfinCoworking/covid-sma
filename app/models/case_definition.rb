class CaseDefinition < ApplicationRecord
  enum case_type: { sospechoso: 0, pendiente: 1, positivo: 2, negativo: 3 }
  belongs_to :diagnostic_method, optional: true

  validates_presence_of :diagnostic_method, if: Proc.new { |case_d| case_d.positivo? || case_d.negativo? }
end
