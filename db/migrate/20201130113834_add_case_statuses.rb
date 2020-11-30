class AddCaseStatuses < ActiveRecord::Migration[5.2]
  def change
    CaseStatus.create(name: 'Sospechoso')
    CaseStatus.create(name: 'Pendiente')
    CaseStatus.create(name: 'Positivo')
    CaseStatus.create(name: 'Negativo')
    CaseStatus.create(name: 'Recuperado')
    CaseStatus.create(name: 'Fallecido')
  end
end
