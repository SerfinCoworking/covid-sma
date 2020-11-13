class CaseDefinition < ApplicationRecord
  enum case_type: { sospechoso: 0, confirmado: 1 }
  belongs_to :diagnostic_method, optional: true

  validates_presence_of :diagnostic_method, if: Proc.new { |case_d| case_d.confirmado? }
end
