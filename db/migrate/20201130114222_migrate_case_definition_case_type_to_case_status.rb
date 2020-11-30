class MigrateCaseDefinitionCaseTypeToCaseStatus < ActiveRecord::Migration[5.2]
  def change
    CaseDefinition.find_each do |cased|
      if cased.sospechoso?
        cased.case_status = CaseStatus.find_by_name('Sospechoso')
      elsif cased.pendiente?
        cased.case_status = CaseStatus.find_by_name('Pendiente')
      elsif cased.positivo?
        cased.case_status = CaseStatus.find_by_name('Positivo')
      elsif cased.negativo?
        cased.case_status = CaseStatus.find_by_name('Negativo')
      elsif cased.recuperado?
        cased.case_status = CaseStatus.find_by_name('Recuperado')
      elsif cased.fallecido?
        cased.case_status = CaseStatus.find_by_name('Fallecido')
      end
      cased.save(validate: false)
    end
  end
end
