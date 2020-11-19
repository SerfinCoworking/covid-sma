class CovidProfile < ApplicationRecord
  enum status: { sospechoso: '0', pendiente: '1', positivo: '2', negativo: '3', recuperado: '4', fallecido: '5' }
  
  belongs_to :patient
  belongs_to :epidemic_sheet

  def self.create_with_epidemic_sheet(a_sheet)
    self.create(
      epidemic_sheet: a_sheet,
      status: a_sheet.case_definition.case_type,
      patient: a_sheet.patient,
      init_symptom_date: a_sheet.init_symptom_date
    )
  end
end